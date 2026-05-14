const http = require("http");
const https = require("https");
const net = require("net");
const tls = require("tls");
const dns = require("dns").promises;
const fs = require("fs");
const path = require("path");

const PORT = Number(process.env.PORT || 3000);
const PUBLIC_DIR = path.join(__dirname, "public");
const MAX_PORTS = 12;
const PORT_TIMEOUT_MS = 1200;
const HTTP_TIMEOUT_MS = 5000;
const TLS_TIMEOUT_MS = 5000;

const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon"
};

const COMMON_PORTS = [80, 443, 8080, 8443, 22, 25, 53, 110, 143, 993, 995, 3306];

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store"
  });
  res.end(JSON.stringify(payload));
}

function normalizeTarget(value) {
  const raw = String(value || "").trim();
  if (!raw) {
    throw new Error("请输入要收集的域名或 URL。");
  }

  const withoutProtocol = raw.replace(/^[a-z][a-z0-9+.-]*:\/\//i, "");
  const host = withoutProtocol.split(/[/?#:]/)[0].trim().toLowerCase();

  if (!/^(?!-)[a-z0-9.-]{1,253}(?<!-)$/.test(host) || !host.includes(".")) {
    throw new Error("目标格式无效，请输入 example.com 或 https://example.com。");
  }

  return host;
}

function parsePorts(value) {
  const requested = String(value || "")
    .split(",")
    .map((item) => Number(item.trim()))
    .filter((port) => Number.isInteger(port) && port >= 1 && port <= 65535);

  const ports = requested.length > 0 ? requested : COMMON_PORTS;
  return [...new Set(ports)].slice(0, MAX_PORTS);
}

async function resolveRecord(host, type) {
  try {
    return await dns.resolve(host, type);
  } catch (error) {
    return [];
  }
}

async function collectDns(host) {
  const [a, aaaa, mx, ns, txt, cname] = await Promise.all([
    resolveRecord(host, "A"),
    resolveRecord(host, "AAAA"),
    resolveRecord(host, "MX"),
    resolveRecord(host, "NS"),
    resolveRecord(host, "TXT"),
    resolveRecord(host, "CNAME")
  ]);
  const lookupAddresses = await lookupHostAddresses(host);

  return {
    a: a.length > 0 ? a : lookupAddresses.filter((item) => item.family === 4).map((item) => item.address),
    aaaa: aaaa.length > 0 ? aaaa : lookupAddresses.filter((item) => item.family === 6).map((item) => item.address),
    mx: mx.map((record) => `${record.exchange} (priority ${record.priority})`),
    ns,
    txt: txt.map((record) => record.join("")),
    cname
  };
}

async function lookupHostAddresses(host) {
  try {
    return await dns.lookup(host, { all: true });
  } catch (error) {
    return [];
  }
}

function requestHead(protocol, host) {
  return new Promise((resolve) => {
    const client = protocol === "https:" ? https : http;
    const req = client.request(
      {
        protocol,
        host,
        method: "HEAD",
        path: "/",
        timeout: HTTP_TIMEOUT_MS,
        headers: {
          "User-Agent": "domain-intel-collector/1.0"
        }
      },
      (res) => {
        res.resume();
        resolve({
          ok: true,
          url: `${protocol}//${host}/`,
          statusCode: res.statusCode,
          statusMessage: res.statusMessage,
          headers: pickHeaders(res.headers)
        });
      }
    );

    req.on("timeout", () => req.destroy(new Error("请求超时")));
    req.on("error", (error) => {
      resolve({
        ok: false,
        url: `${protocol}//${host}/`,
        error: error.message
      });
    });
    req.end();
  });
}

function pickHeaders(headers) {
  const interesting = [
    "server",
    "x-powered-by",
    "content-type",
    "location",
    "strict-transport-security",
    "content-security-policy",
    "x-frame-options",
    "x-content-type-options"
  ];

  return Object.fromEntries(
    interesting
      .filter((name) => headers[name])
      .map((name) => [name, Array.isArray(headers[name]) ? headers[name].join(", ") : headers[name]])
  );
}

async function collectHttp(host) {
  const [httpsResult, httpResult] = await Promise.all([requestHead("https:", host), requestHead("http:", host)]);
  return [httpsResult, httpResult];
}

function collectTls(host) {
  return new Promise((resolve) => {
    const socket = tls.connect(
      {
        host,
        port: 443,
        servername: host,
        timeout: TLS_TIMEOUT_MS,
        rejectUnauthorized: false
      },
      () => {
        const certificate = socket.getPeerCertificate();
        socket.end();

        if (!certificate || Object.keys(certificate).length === 0) {
          resolve({ ok: false, error: "未返回证书信息。" });
          return;
        }

        resolve({
          ok: true,
          subject: certificate.subject || {},
          issuer: certificate.issuer || {},
          validFrom: certificate.valid_from,
          validTo: certificate.valid_to,
          subjectAltName: certificate.subjectaltname || ""
        });
      }
    );

    socket.on("timeout", () => socket.destroy(new Error("TLS 连接超时")));
    socket.on("error", (error) => resolve({ ok: false, error: error.message }));
  });
}

function checkPort(host, port) {
  return new Promise((resolve) => {
    const startedAt = Date.now();
    const socket = net.createConnection({ host, port, timeout: PORT_TIMEOUT_MS });

    socket.on("connect", () => {
      socket.end();
      resolve({ port, open: true, latencyMs: Date.now() - startedAt });
    });
    socket.on("timeout", () => {
      socket.destroy();
      resolve({ port, open: false, error: "timeout" });
    });
    socket.on("error", (error) => resolve({ port, open: false, error: error.code || error.message }));
  });
}

async function collectPorts(host, ports) {
  return Promise.all(ports.map((port) => checkPort(host, port)));
}

async function handleCollect(req, res) {
  const requestUrl = new URL(req.url, `http://${req.headers.host}`);

  try {
    const host = normalizeTarget(requestUrl.searchParams.get("target"));
    const ports = parsePorts(requestUrl.searchParams.get("ports"));
    const [dnsRecords, httpResults, tlsInfo, portResults] = await Promise.all([
      collectDns(host),
      collectHttp(host),
      collectTls(host),
      collectPorts(host, ports)
    ]);

    sendJson(res, 200, {
      target: host,
      collectedAt: new Date().toISOString(),
      limits: {
        maxPorts: MAX_PORTS,
        portTimeoutMs: PORT_TIMEOUT_MS
      },
      dns: dnsRecords,
      http: httpResults,
      tls: tlsInfo,
      ports: portResults
    });
  } catch (error) {
    sendJson(res, 400, { error: error.message });
  }
}

function sendFile(req, res) {
  const requestUrl = new URL(req.url, `http://${req.headers.host}`);
  const safePath = path
    .normalize(decodeURIComponent(requestUrl.pathname))
    .replace(/^[/\\]+/, "")
    .replace(/^(\.\.[/\\])+/, "");
  const relativePath = safePath === "" ? "index.html" : safePath;
  const filePath = path.join(PUBLIC_DIR, relativePath);

  if (!filePath.startsWith(PUBLIC_DIR)) {
    res.writeHead(403);
    res.end("Forbidden");
    return;
  }

  fs.stat(filePath, (statError, stats) => {
    if (statError || !stats.isFile()) {
      res.writeHead(404);
      res.end("Not found");
      return;
    }

    const extension = path.extname(filePath).toLowerCase();
    res.writeHead(200, {
      "Content-Type": MIME_TYPES[extension] || "application/octet-stream"
    });
    fs.createReadStream(filePath).pipe(res);
  });
}

const server = http.createServer((req, res) => {
  if (req.method === "GET" && req.url.startsWith("/api/collect")) {
    handleCollect(req, res);
    return;
  }

  if (req.method === "GET") {
    sendFile(req, res);
    return;
  }

  res.writeHead(405, { Allow: "GET" });
  res.end("Method not allowed");
});

server.listen(PORT, () => {
  console.log(`Domain intel collector running at http://localhost:${PORT}`);
});

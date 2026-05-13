const http = require("http");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const PORT = Number(process.env.PORT || 3000);
const PUBLIC_DIR = path.join(__dirname, "public");
const UPLOAD_DIR = path.join(__dirname, "uploads");
const MAX_UPLOAD_SIZE = 50 * 1024 * 1024;

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

fs.mkdirSync(UPLOAD_DIR, { recursive: true });

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store"
  });
  res.end(JSON.stringify(payload));
}

function sendFile(req, res) {
  const requestUrl = new URL(req.url, `http://${req.headers.host}`);
  const safePath = path
    .normalize(decodeURIComponent(requestUrl.pathname))
    .replace(/^(\.\.[/\\])+/, "");
  const relativePath = safePath === "/" ? "/index.html" : safePath;
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

function parseMultipart(buffer, contentType) {
  const boundaryMatch = contentType.match(/boundary=(?:"([^"]+)"|([^;]+))/i);
  if (!boundaryMatch) {
    throw new Error("Missing multipart boundary.");
  }

  const boundary = `--${boundaryMatch[1] || boundaryMatch[2]}`;
  const body = buffer.toString("binary");
  const parts = body.split(boundary).slice(1, -1);

  return parts
    .map((part) => {
      const trimmedPart = part.replace(/^\r\n/, "").replace(/\r\n$/, "");
      const separatorIndex = trimmedPart.indexOf("\r\n\r\n");

      if (separatorIndex === -1) {
        return null;
      }

      const rawHeaders = trimmedPart.slice(0, separatorIndex);
      const content = trimmedPart.slice(separatorIndex + 4);
      const disposition = rawHeaders.match(/content-disposition:.*name="([^"]+)"(?:; filename="([^"]*)")?/i);

      if (!disposition || !disposition[2]) {
        return null;
      }

      const contentTypeMatch = rawHeaders.match(/content-type:\s*([^\r\n]+)/i);

      return {
        fieldName: disposition[1],
        originalName: path.basename(disposition[2]),
        mimeType: contentTypeMatch ? contentTypeMatch[1].trim() : "application/octet-stream",
        data: Buffer.from(content, "binary")
      };
    })
    .filter(Boolean);
}

function safeUploadName(originalName) {
  const extension = path.extname(originalName);
  const baseName = path
    .basename(originalName, extension)
    .replace(/[^a-z0-9._-]+/gi, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80) || "upload";
  const suffix = crypto.randomBytes(5).toString("hex");

  return `${baseName}-${suffix}${extension}`;
}

function handleUpload(req, res) {
  const contentType = req.headers["content-type"] || "";
  const contentLength = Number(req.headers["content-length"] || 0);

  if (!contentType.includes("multipart/form-data")) {
    sendJson(res, 415, { error: "请使用表单上传文件。" });
    return;
  }

  if (contentLength > MAX_UPLOAD_SIZE) {
    sendJson(res, 413, { error: "文件太大，单次上传最大 50MB。" });
    return;
  }

  const chunks = [];
  let received = 0;

  req.on("data", (chunk) => {
    received += chunk.length;

    if (received > MAX_UPLOAD_SIZE) {
      req.destroy();
      return;
    }

    chunks.push(chunk);
  });

  req.on("end", () => {
    try {
      const files = parseMultipart(Buffer.concat(chunks), contentType);

      if (files.length === 0) {
        sendJson(res, 400, { error: "没有收到文件。" });
        return;
      }

      const savedFiles = files.map((file) => {
        const storedName = safeUploadName(file.originalName);
        const destination = path.join(UPLOAD_DIR, storedName);

        fs.writeFileSync(destination, file.data);

        return {
          originalName: file.originalName,
          storedName,
          mimeType: file.mimeType,
          size: file.data.length
        };
      });

      sendJson(res, 201, { files: savedFiles });
    } catch (error) {
      sendJson(res, 400, { error: error.message });
    }
  });

  req.on("error", () => {
    sendJson(res, 500, { error: "上传中断，请重试。" });
  });
}

const server = http.createServer((req, res) => {
  if (req.method === "POST" && req.url === "/upload") {
    handleUpload(req, res);
    return;
  }

  if (req.method === "GET") {
    sendFile(req, res);
    return;
  }

  res.writeHead(405, { Allow: "GET, POST" });
  res.end("Method not allowed");
});

server.listen(PORT, () => {
  console.log(`File upload site running at http://localhost:${PORT}`);
});

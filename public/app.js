const form = document.querySelector("#collectForm");
const targetInput = document.querySelector("#targetInput");
const portsInput = document.querySelector("#portsInput");
const collectButton = document.querySelector("#collectButton");
const statusBox = document.querySelector("#status");
const results = document.querySelector("#results");
const resultTarget = document.querySelector("#resultTarget");
const collectedAt = document.querySelector("#collectedAt");
const dnsRecords = document.querySelector("#dnsRecords");
const httpRecords = document.querySelector("#httpRecords");
const tlsRecord = document.querySelector("#tlsRecord");
const portRecords = document.querySelector("#portRecords");

function setStatus(message, type = "") {
  statusBox.textContent = message;
  statusBox.className = `status ${type}`.trim();
}

function clearNode(node) {
  node.replaceChildren();
}

function appendEmpty(node, text) {
  const empty = document.createElement("p");
  empty.className = "empty";
  empty.textContent = text;
  node.append(empty);
}

function renderKeyValues(node, entries) {
  clearNode(node);

  const visibleEntries = entries.filter(([, value]) => {
    if (Array.isArray(value)) return value.length > 0;
    return value !== undefined && value !== null && value !== "";
  });

  if (visibleEntries.length === 0) {
    appendEmpty(node, "没有收集到可展示的信息。");
    return;
  }

  visibleEntries.forEach(([label, value]) => {
    const row = document.createElement("div");
    row.className = "kvRow";

    const key = document.createElement("dt");
    key.textContent = label;

    const val = document.createElement("dd");
    val.textContent = Array.isArray(value) ? value.join("\n") : String(value);

    row.append(key, val);
    node.append(row);
  });
}

function renderDns(data) {
  renderKeyValues(dnsRecords, [
    ["A", data.a],
    ["AAAA", data.aaaa],
    ["CNAME", data.cname],
    ["MX", data.mx],
    ["NS", data.ns],
    ["TXT", data.txt]
  ]);
}

function renderHttp(records) {
  clearNode(httpRecords);

  records.forEach((record) => {
    const item = document.createElement("div");
    item.className = "httpItem";

    const title = document.createElement("strong");
    title.textContent = record.url;

    const status = document.createElement("p");
    status.textContent = record.ok
      ? `${record.statusCode} ${record.statusMessage || ""}`.trim()
      : record.error;

    item.append(title, status);

    if (record.headers && Object.keys(record.headers).length > 0) {
      const list = document.createElement("dl");
      list.className = "miniList";
      Object.entries(record.headers).forEach(([name, value]) => {
        const key = document.createElement("dt");
        key.textContent = name;
        const val = document.createElement("dd");
        val.textContent = value;
        list.append(key, val);
      });
      item.append(list);
    }

    httpRecords.append(item);
  });
}

function renderTls(data) {
  if (!data.ok) {
    renderKeyValues(tlsRecord, [["错误", data.error]]);
    return;
  }

  renderKeyValues(tlsRecord, [
    ["主体", Object.entries(data.subject || {}).map(([key, value]) => `${key}: ${value}`)],
    ["签发者", Object.entries(data.issuer || {}).map(([key, value]) => `${key}: ${value}`)],
    ["生效时间", data.validFrom],
    ["过期时间", data.validTo],
    ["备用名称", data.subjectAltName]
  ]);
}

function renderPorts(records) {
  clearNode(portRecords);

  records.forEach((record) => {
    const item = document.createElement("div");
    item.className = `port ${record.open ? "open" : "closed"}`;
    item.innerHTML = `
      <span>${record.port}</span>
      <strong>${record.open ? "开放" : "未开放"}</strong>
      <small>${record.open ? `${record.latencyMs} ms` : record.error || ""}</small>
    `;
    portRecords.append(item);
  });
}

function renderResults(data) {
  resultTarget.textContent = data.target;
  collectedAt.textContent = new Date(data.collectedAt).toLocaleString();
  renderDns(data.dns);
  renderHttp(data.http);
  renderTls(data.tls);
  renderPorts(data.ports);
  results.hidden = false;
}

form.addEventListener("submit", async (event) => {
  event.preventDefault();

  const params = new URLSearchParams({
    target: targetInput.value,
    ports: portsInput.value
  });

  collectButton.disabled = true;
  setStatus("正在收集信息...");

  try {
    const response = await fetch(`/api/collect?${params.toString()}`);
    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "收集失败。");
    }

    renderResults(data);
    setStatus(`完成。端口检查最多 ${data.limits.maxPorts} 个，超出的端口会被自动忽略。`, "success");
  } catch (error) {
    setStatus(error.message, "error");
  } finally {
    collectButton.disabled = false;
  }
});

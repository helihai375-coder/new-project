const form = document.querySelector("#uploadForm");
const fileInput = document.querySelector("#fileInput");
const chooseButton = document.querySelector("#chooseButton");
const uploadButton = document.querySelector("#uploadButton");
const fileList = document.querySelector("#fileList");
const statusBox = document.querySelector("#status");

let selectedFiles = [];

function formatBytes(bytes) {
  if (bytes === 0) return "0 B";

  const units = ["B", "KB", "MB", "GB"];
  const index = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
  const value = bytes / Math.pow(1024, index);

  return `${value.toFixed(value >= 10 || index === 0 ? 0 : 1)} ${units[index]}`;
}

function setStatus(message, type = "") {
  statusBox.textContent = message;
  statusBox.className = `status ${type}`.trim();
}

function renderFiles() {
  fileList.innerHTML = "";
  uploadButton.disabled = selectedFiles.length === 0;

  selectedFiles.forEach((file) => {
    const item = document.createElement("div");
    item.className = "fileItem";

    const name = document.createElement("div");
    name.className = "fileName";
    name.textContent = file.name;

    const size = document.createElement("div");
    size.className = "fileSize";
    size.textContent = formatBytes(file.size);

    item.append(name, size);
    fileList.append(item);
  });

  if (selectedFiles.length > 0) {
    setStatus(`已选择 ${selectedFiles.length} 个文件。`);
  }
}

function setFiles(files) {
  selectedFiles = Array.from(files);
  renderFiles();
}

chooseButton.addEventListener("click", () => fileInput.click());

fileInput.addEventListener("change", (event) => {
  setFiles(event.target.files);
});

["dragenter", "dragover"].forEach((eventName) => {
  form.addEventListener(eventName, (event) => {
    event.preventDefault();
    form.classList.add("isDragging");
  });
});

["dragleave", "drop"].forEach((eventName) => {
  form.addEventListener(eventName, (event) => {
    event.preventDefault();
    form.classList.remove("isDragging");
  });
});

form.addEventListener("drop", (event) => {
  setFiles(event.dataTransfer.files);
});

uploadButton.addEventListener("click", async () => {
  if (selectedFiles.length === 0) return;

  const data = new FormData();
  selectedFiles.forEach((file) => data.append("files", file));

  uploadButton.disabled = true;
  setStatus("正在上传...");

  try {
    const response = await fetch("/upload", {
      method: "POST",
      body: data
    });
    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.error || "上传失败。");
    }

    fileInput.value = "";
    selectedFiles = [];
    renderFiles();
    setStatus(`上传成功：${result.files.length} 个文件已保存。`, "success");
  } catch (error) {
    uploadButton.disabled = false;
    setStatus(error.message, "error");
  }
});

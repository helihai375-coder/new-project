#!/bin/bash

# ==============================
# 保存报告到 VMware 主机共享文件夹
# 用法: ./savehost example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./savehost 域名"
    echo "示例: ./savehost example.com"
    exit 1
fi

DOMAIN=$(echo "$1" | sed 's#https://##;s#http://##;s#/##g')

RECON_DIR="${DOMAIN}-recon"
MOUNT_DIR="/mnt/hgfs"
SHARE_NAME="kali-share"
SHARE_DIR="$MOUNT_DIR/$SHARE_NAME"

echo "[+] 目标: $DOMAIN"
echo "[+] 本地报告目录: $RECON_DIR"
echo "[+] 主机共享目录: $SHARE_DIR"

if [ ! -d "$RECON_DIR" ]; then
    echo "[-] 未找到报告目录: $RECON_DIR"
    echo "请先运行:"
    echo "./start $DOMAIN"
    exit 1
fi

if [ ! -d "$MOUNT_DIR" ]; then
    echo "[+] 创建挂载目录: $MOUNT_DIR"
    sudo mkdir -p "$MOUNT_DIR"
fi

if ! command -v vmhgfs-fuse >/dev/null 2>&1; then
    echo "[-] 未检测到 vmhgfs-fuse"
    echo "请先安装 VMware 工具:"
    echo "sudo apt update"
    echo "sudo apt install open-vm-tools open-vm-tools-desktop -y"
    echo "reboot"
    exit 1
fi

if ! mount | grep -q "$MOUNT_DIR"; then
    echo "[+] 正在挂载 VMware 共享文件夹..."
    sudo vmhgfs-fuse .host:/ "$MOUNT_DIR" -o allow_other
fi

if [ ! -d "$SHARE_DIR" ]; then
    echo "[-] 未找到共享文件夹: $SHARE_DIR"
    echo "请确认 VMware 共享文件夹名称是: $SHARE_NAME"
    echo "当前可见共享目录:"
    ls "$MOUNT_DIR"
    exit 1
fi

echo "[+] 正在复制报告目录到主机共享文件夹..."
sudo rm -rf "$SHARE_DIR/$RECON_DIR"
sudo cp -r "$RECON_DIR" "$SHARE_DIR/"

if command -v zip >/dev/null 2>&1; then
    echo "[+] 正在生成压缩包..."
    zip -r "${DOMAIN}-recon.zip" "$RECON_DIR" >/dev/null
    sudo cp "${DOMAIN}-recon.zip" "$SHARE_DIR/"
else
    echo "[!] 未安装 zip，跳过压缩包生成"
    echo "如需安装: sudo apt install zip -y"
fi

echo "[+] 保存完成！"
echo "[+] Windows 主机共享文件夹里应该可以看到:"
echo "$RECON_DIR"
echo "${DOMAIN}-recon.zip"

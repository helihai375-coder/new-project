#!/usr/bin/env bash
# 更新常见的 Debian/Ubuntu/Kali 系 Linux 系统。

set -euo pipefail

if ! command -v apt >/dev/null 2>&1; then
  echo "这个脚本适用于基于 apt 的 Linux 系统。"
  exit 1
fi

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

echo "系统更新完成。"

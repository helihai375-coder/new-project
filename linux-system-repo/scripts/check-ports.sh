#!/usr/bin/env bash
# 显示正在监听的 TCP 和 UDP 端口。

set -euo pipefail

if command -v ss >/dev/null 2>&1; then
  ss -tulpen
else
  netstat -tulpen
fi

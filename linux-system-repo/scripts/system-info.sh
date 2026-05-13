#!/usr/bin/env bash
# 显示常用 Linux 系统信息。

set -euo pipefail

echo "== 主机信息 =="
hostnamectl || hostname

echo
echo "== 内核信息 =="
uname -a

echo
echo "== 运行时间 =="
uptime

echo
echo "== CPU =="
lscpu | sed -n '1,12p'

echo
echo "== 内存信息 =="
free -h

echo
echo "== 磁盘信息 =="
df -h

echo
echo "== 网络地址 =="
ip addr show

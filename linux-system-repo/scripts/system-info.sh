#!/usr/bin/env bash
# Show useful Linux system information.

set -euo pipefail

echo "== Host =="
hostnamectl || hostname

echo
echo "== Kernel =="
uname -a

echo
echo "== Uptime =="
uptime

echo
echo "== CPU =="
lscpu | sed -n '1,12p'

echo
echo "== Memory =="
free -h

echo
echo "== Disk =="
df -h

echo
echo "== Network Addresses =="
ip addr show


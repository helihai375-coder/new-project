#!/bin/bash

# ==============================
# Nmap 端口收集脚本
# 用法: ./mynmap example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./mynmap 域名或 IP"
    echo "示例: ./mynmap example.com"
    exit 1
fi

TARGET=$(echo "$1" | sed 's#https://##;s#http://##;s#/##g')
DIR="${TARGET}-nmap-info"

mkdir -p "$DIR"

echo "[+] 目标: $TARGET"
echo "[+] 保存目录: $DIR"

if ! command -v nmap >/dev/null 2>&1; then
    echo "[-] 未检测到 nmap，请先安装:"
    echo "sudo apt install nmap -y"
    exit 1
fi

echo "[+] 1. 快速端口扫描..."
nmap -Pn --top-ports 1000 "$TARGET" -oN "$DIR/quick_ports.txt"

echo "[+] 2. 全端口扫描..."
nmap -Pn -p- "$TARGET" -oN "$DIR/all_ports.txt"

echo "[+] 3. 服务版本识别..."
nmap -Pn -sV "$TARGET" -oN "$DIR/service_version.txt"

echo "[+] 4. 操作系统识别..."
nmap -Pn -O "$TARGET" -oN "$DIR/os_detect.txt" 2>/dev/null

echo "[+] 5. 默认脚本扫描..."
nmap -Pn -sC -sV "$TARGET" -oN "$DIR/default_scripts.txt"

echo "[+] 6. 提取开放端口..."
grep -E "^[0-9]+/tcp" "$DIR/all_ports.txt" 2>/dev/null \
| awk -F/ '{print $1}' \
| tr '\n' ',' \
| sed 's/,$//' > "$DIR/open_ports.txt"

OPEN_PORTS=$(cat "$DIR/open_ports.txt")

if [ -n "$OPEN_PORTS" ]; then
    echo "[+] 开放端口: $OPEN_PORTS"
    echo "[+] 7. 针对开放端口深度扫描..."
    nmap -Pn -sV -sC -p "$OPEN_PORTS" "$TARGET" -oN "$DIR/deep_scan.txt"
else
    echo "[-] 未发现开放端口"
    touch "$DIR/deep_scan.txt"
fi

cat > "$DIR/summary.txt" << EOF
Nmap 端口收集报告

目标: $TARGET
扫描时间: $(date)

生成文件:
- quick_ports.txt       快速端口扫描结果
- all_ports.txt         全端口扫描结果
- service_version.txt   服务版本识别结果
- os_detect.txt         操作系统识别结果
- default_scripts.txt   默认脚本扫描结果
- open_ports.txt        开放端口列表
- deep_scan.txt         针对开放端口的深度扫描结果

重点查看:
- 21                    FTP
- 22                    SSH
- 23                    Telnet
- 80                    HTTP
- 443                   HTTPS
- 3306                  MySQL
- 3389                  RDP
- 6379                  Redis
- 8080                  常见 Web / 管理端口
- 8443                  常见 HTTPS 管理端口
EOF

echo "[+] 扫描完成！"
echo "[+] 结果保存在: $DIR"

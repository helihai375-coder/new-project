#!/bin/bash

# ==============================
# WhatWeb 网站指纹收集脚本
# 用法: ./mywhatweb example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./mywhatweb 域名"
    echo "示例: ./mywhatweb example.com"
    echo "示例: ./mywhatweb https://example.com"
    exit 1
fi

TARGET=$1

DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')
DIR="${DOMAIN}-whatweb-info"

if [[ "$TARGET" != http://* && "$TARGET" != https://* ]]; then
    URL="https://$DOMAIN"
else
    URL="$TARGET"
fi

mkdir -p "$DIR"

echo "[+] 目标: $URL"
echo "[+] 保存目录: $DIR"

if ! command -v whatweb >/dev/null 2>&1; then
    echo "[-] 未检测到 whatweb，请先安装:"
    echo "sudo apt install whatweb -y"
    exit 1
fi

echo "[+] 1. 基础指纹识别..."
whatweb "$URL" > "$DIR/whatweb_basic.txt" 2>&1

echo "[+] 2. 详细指纹识别..."
whatweb -v "$URL" > "$DIR/whatweb_verbose.txt" 2>&1

echo "[+] 3. 高强度扫描..."
whatweb -a 3 "$URL" > "$DIR/whatweb_aggressive.txt" 2>&1

echo "[+] 4. HTTP 指纹识别..."
whatweb "http://$DOMAIN" > "$DIR/http_whatweb.txt" 2>&1

echo "[+] 5. HTTPS 指纹识别..."
whatweb "https://$DOMAIN" > "$DIR/https_whatweb.txt" 2>&1

cat > "$DIR/summary.txt" << EOF
WhatWeb 网站指纹识别报告

目标: $URL
域名: $DOMAIN
扫描时间: $(date)

生成文件:
- whatweb_basic.txt       基础指纹识别
- whatweb_verbose.txt     详细指纹识别
- whatweb_aggressive.txt  高强度指纹识别
- http_whatweb.txt        HTTP 指纹识别
- https_whatweb.txt       HTTPS 指纹识别

重点查看:
- HTTPServer              Web 服务器
- Title                   网站标题
- Country                 服务器或 IP 所属国家
- IP                      解析到的 IP
- HTML5                   是否使用 HTML5
- Cookies                 Cookie 信息
- Cloudflare              是否使用 Cloudflare
- WordPress               是否使用 WordPress
- PHP                     是否使用 PHP
EOF

echo "[+] 扫描完成！"
echo "[+] 结果保存在: $DIR"

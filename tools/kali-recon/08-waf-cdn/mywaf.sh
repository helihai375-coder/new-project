#!/bin/bash

# ==============================
# WAF / CDN 识别脚本
# 用法: ./mywaf example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./mywaf 域名"
    echo "示例: ./mywaf example.com"
    echo "示例: ./mywaf https://example.com"
    exit 1
fi

TARGET=$1

DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')
DIR="${DOMAIN}-waf-info"

mkdir -p "$DIR"

echo "[+] 目标: $DOMAIN"
echo "[+] 保存目录: $DIR"

if ! command -v wafw00f >/dev/null 2>&1; then
    echo "[-] 未检测到 wafw00f，请先安装:"
    echo "sudo apt install wafw00f -y"
    exit 1
fi

echo "[+] 1. 基础 WAF/CDN 识别..."
wafw00f "http://$DOMAIN" > "$DIR/http_waf.txt" 2>&1

echo "[+] 2. HTTPS WAF/CDN 识别..."
wafw00f "https://$DOMAIN" > "$DIR/https_waf.txt" 2>&1

echo "[+] 3. 详细 WAF/CDN 识别..."
wafw00f -v "https://$DOMAIN" > "$DIR/waf_verbose.txt" 2>&1

cat > "$DIR/summary.txt" << EOF
WAF / CDN 识别报告

目标: $DOMAIN
扫描时间: $(date)

生成文件:
- http_waf.txt        保存 HTTP 协议下的 WAF/CDN 识别结果
- https_waf.txt       保存 HTTPS 协议下的 WAF/CDN 识别结果
- waf_verbose.txt     保存更详细的 WAF/CDN 检测过程

重点查看:
- Cloudflare          常见 CDN / WAF
- Akamai              常见 CDN / WAF
- AWS WAF             亚马逊云 WAF
- Imperva             常见企业级 WAF
- F5 BIG-IP           常见负载均衡 / WAF
- Aliyun              阿里云安全防护
- Tencent             腾讯云安全防护
- No WAF detected     未检测到明显 WAF
EOF

echo "[+] 识别完成！"
echo "[+] 结果保存在: $DIR"

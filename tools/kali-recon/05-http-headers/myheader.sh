#!/bin/bash

# ==============================
# HTTP Header 信息收集脚本
# 用法: ./myheader example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./myheader 域名"
    echo "示例: ./myheader example.com"
    echo "示例: ./myheader https://example.com"
    exit 1
fi

TARGET=$1

DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')

DIR="${DOMAIN}-headers-info"

mkdir -p "$DIR"

echo "[+] 目标: $DOMAIN"
echo "[+] 保存目录: $DIR"

if ! command -v curl >/dev/null 2>&1; then
    echo "[-] 未检测到 curl，请先安装:"
    echo "sudo apt install curl -y"
    exit 1
fi

echo "[+] 1. 收集 HTTP Header..."
curl -I -L --max-time 15 "http://$DOMAIN" > "$DIR/http_headers.txt" 2>/dev/null

echo "[+] 2. 收集 HTTPS Header..."
curl -I -L --max-time 15 "https://$DOMAIN" > "$DIR/https_headers.txt" 2>/dev/null

echo "[+] 3. 收集完整 HTTPS 请求过程..."
curl -v -I -L --max-time 15 "https://$DOMAIN" > "$DIR/https_verbose_headers.txt" 2>&1

cat > "$DIR/summary.txt" << EOF
HTTP Header 收集报告

目标: $DOMAIN
扫描时间: $(date)

生成文件:
- http_headers.txt              保存 HTTP 协议下的响应头信息
- https_headers.txt             保存 HTTPS 协议下的响应头信息
- https_verbose_headers.txt     保存更详细的 HTTPS 请求和响应过程信息

重点查看:
- Server                        查看 Web 服务器类型，例如 nginx、Apache、Cloudflare
- X-Powered-By                  查看网站后端技术，例如 PHP、ASP.NET
- Set-Cookie                    查看网站返回的 Cookie 信息
- Location                      查看网站跳转地址
- Strict-Transport-Security     查看是否启用 HSTS 强制 HTTPS
- Content-Security-Policy       查看 CSP 内容安全策略
- X-Frame-Options               查看是否防止点击劫持
- X-Content-Type-Options        查看是否防止 MIME 类型嗅探
- Referrer-Policy               查看来源地址 Referer 泄露控制策略
- Permissions-Policy            查看浏览器权限控制策略
- cf-ray                        Cloudflare 请求追踪 ID
- cf-cache-status               Cloudflare 缓存状态
EOF

echo "[+] 收集完成！"
echo "[+] 结果保存在: $DIR"

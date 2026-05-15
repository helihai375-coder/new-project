#!/bin/bash

# ==============================
# Gobuster 目录扫描脚本
# 用法: ./mydir example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./mydir 域名"
    echo "示例: ./mydir example.com"
    echo "示例: ./mydir https://example.com"
    exit 1
fi

TARGET=$1

DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')
DIR="${DOMAIN}-dir-info"

WORDLIST="/usr/share/wordlists/dirb/common.txt"

mkdir -p "$DIR"

echo "[+] 目标: $DOMAIN"
echo "[+] 保存目录: $DIR"

if ! command -v gobuster >/dev/null 2>&1; then
    echo "[-] 未检测到 gobuster，请先安装:"
    echo "sudo apt install gobuster -y"
    exit 1
fi

if [ ! -f "$WORDLIST" ]; then
    echo "[-] 未找到字典文件: $WORDLIST"
    echo "可以尝试安装:"
    echo "sudo apt install dirb -y"
    exit 1
fi

echo "[+] 1. 扫描 HTTP 目录..."
gobuster dir \
-u "http://$DOMAIN" \
-w "$WORDLIST" \
-t 20 \
-x php,html,txt,js \
-o "$DIR/http_dirs.txt"

echo "[+] 2. 扫描 HTTPS 目录..."
gobuster dir \
-u "https://$DOMAIN" \
-w "$WORDLIST" \
-t 20 \
-x php,html,txt,js \
-o "$DIR/https_dirs.txt"

cat > "$DIR/summary.txt" << EOF
目录扫描报告

目标: $DOMAIN
扫描时间: $(date)

生成文件:
- http_dirs.txt       保存 HTTP 协议下发现的目录和文件
- https_dirs.txt      保存 HTTPS 协议下发现的目录和文件

重点查看:
- /admin              常见后台路径
- /login              常见登录入口
- /api                常见接口路径
- /upload             常见上传目录
- /backup             常见备份目录
- /test               常见测试目录
- Status 200          页面正常存在
- Status 301/302      页面存在跳转
- Status 403          禁止访问，但路径可能存在
EOF

echo "[+] 扫描完成！"
echo "[+] 结果保存在: $DIR"

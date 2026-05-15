#!/bin/bash

# ==============================
# 子域名收集脚本
# 用法: ./mysub example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./mysub 域名"
    echo "示例: ./mysub example.com"
    exit 1
fi

DOMAIN=$(echo "$1" | sed 's#https://##;s#http://##;s#/##g')
DIR="${DOMAIN}-subdomain-info"

mkdir -p "$DIR"

echo "[+] 目标: $DOMAIN"
echo "[+] 保存目录: $DIR"

echo "[+] 1. 使用 subfinder 收集子域名..."
if command -v subfinder >/dev/null 2>&1; then
    subfinder -d "$DOMAIN" -silent -o "$DIR/subfinder.txt"
else
    echo "[-] 未安装 subfinder，跳过"
    echo "安装命令: sudo apt install subfinder -y"
    touch "$DIR/subfinder.txt"
fi

echo "[+] 2. 使用 amass 被动收集子域名..."
if command -v amass >/dev/null 2>&1; then
    amass enum -passive -d "$DOMAIN" -o "$DIR/amass.txt"
else
    echo "[-] 未安装 amass，跳过"
    echo "安装命令: sudo apt install amass -y"
    touch "$DIR/amass.txt"
fi

echo "[+] 3. 使用 assetfinder 收集子域名..."
if command -v assetfinder >/dev/null 2>&1; then
    assetfinder --subs-only "$DOMAIN" > "$DIR/assetfinder.txt"
else
    echo "[-] 未安装 assetfinder，跳过"
    echo "安装命令: sudo apt install assetfinder -y"
    touch "$DIR/assetfinder.txt"
fi

echo "[+] 4. 合并去重..."
cat "$DIR/subfinder.txt" "$DIR/amass.txt" "$DIR/assetfinder.txt" 2>/dev/null \
| sed '/^$/d' \
| sort -u > "$DIR/all-subdomains.txt"

echo "[+] 5. 验证可解析子域名..."
if command -v dnsx >/dev/null 2>&1; then
    cat "$DIR/all-subdomains.txt" | dnsx -silent -a -resp -o "$DIR/resolved-subdomains.txt"
else
    echo "[-] 未安装 dnsx，使用 host 简单验证"
    > "$DIR/resolved-subdomains.txt"

    while read -r SUB; do
        if host "$SUB" >/dev/null 2>&1; then
            echo "$SUB" >> "$DIR/resolved-subdomains.txt"
        fi
    done < "$DIR/all-subdomains.txt"
fi

cat > "$DIR/summary.txt" << EOF
子域名收集报告

目标: $DOMAIN
扫描时间: $(date)

生成文件:
- subfinder.txt              subfinder 收集到的子域名
- amass.txt                  amass 被动收集到的子域名
- assetfinder.txt            assetfinder 收集到的子域名
- all-subdomains.txt         合并去重后的全部子域名
- resolved-subdomains.txt    已验证可解析的子域名

重点查看:
- admin                      可能是后台
- api                        可能是接口服务
- dev                        可能是开发环境
- test                       可能是测试环境
- staging                    可能是预发布环境
- vpn                        可能是 VPN 入口
- mail                       可能是邮件服务
EOF

echo "[+] 子域名收集完成！"
echo "[+] 全部子域名: $DIR/all-subdomains.txt"
echo "[+] 可解析子域名: $DIR/resolved-subdomains.txt"

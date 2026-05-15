#!/bin/bash

# ==============================
# 总控信息收集脚本
# 用法: ./recon example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./recon 域名"
    echo "示例: ./recon example.com"
    exit 1
fi

TARGET=$1

DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')
OUTDIR="${DOMAIN}-recon"

mkdir -p "$OUTDIR"

echo "[+] 目标: $DOMAIN"
echo "[+] 总保存目录: $OUTDIR"
echo "[+] 开始执行完整信息收集流程..."

echo "[+] 1. WHOIS / DNS 信息收集..."
./whois "$DOMAIN"

echo "[+] 2. 子域名收集..."
./mysub "$DOMAIN"

echo "[+] 3. Nmap 端口扫描..."
./mynmap "$DOMAIN"

echo "[+] 4. WhatWeb 指纹识别..."
./mywhatweb "$DOMAIN"

echo "[+] 5. HTTP Header 收集..."
./myheader "$DOMAIN"

echo "[+] 6. robots.txt / sitemap.xml 收集..."
./myrobots "$DOMAIN"

echo "[+] 7. SSL 证书信息收集..."
./myssl "$DOMAIN"

echo "[+] 8. WAF/CDN 识别..."
./mywaf "$DOMAIN"

echo "[+] 9. 目录扫描..."
./mydir "$DOMAIN"

echo "[+] 10. JS 文件与接口提取..."
./myjs "$DOMAIN"

echo "[+] 11. 漏洞初步扫描..."
if [ -x "./myvuln" ]; then
    ./myvuln "$DOMAIN"
else
    echo "[!] 未找到 myvuln 或不可执行，跳过漏洞初步扫描"
fi

echo "[+] 正在整理结果目录..."

for DIR in \
"${DOMAIN}-domain-info" \
"${DOMAIN}-subdomain-info" \
"${DOMAIN}-nmap-info" \
"${DOMAIN}-whatweb-info" \
"${DOMAIN}-headers-info" \
"${DOMAIN}-robots-info" \
"${DOMAIN}-ssl-info" \
"${DOMAIN}-waf-info" \
"${DOMAIN}-dir-info" \
"${DOMAIN}-js-info" \
"${DOMAIN}-vuln-info"
do
    if [ -d "$DIR" ]; then
        rm -rf "$OUTDIR/$DIR"
        mv "$DIR" "$OUTDIR/"
    fi
done

cat > "$OUTDIR/summary.txt" << EOF
综合信息收集报告

目标: $DOMAIN
扫描时间: $(date)

结果目录:
- ${DOMAIN}-domain-info      WHOIS / DNS / 基础信息
- ${DOMAIN}-subdomain-info   子域名收集与解析验证结果
- ${DOMAIN}-nmap-info        Nmap 端口扫描结果
- ${DOMAIN}-whatweb-info     WhatWeb 网站指纹识别结果
- ${DOMAIN}-headers-info     HTTP Header 响应头信息
- ${DOMAIN}-robots-info      robots.txt / sitemap.xml 收集结果
- ${DOMAIN}-ssl-info         SSL 证书信息
- ${DOMAIN}-waf-info         WAF / CDN 识别结果
- ${DOMAIN}-dir-info         目录扫描结果
- ${DOMAIN}-js-info          JS 文件与接口提取结果
- ${DOMAIN}-vuln-info        漏洞初步扫描结果
EOF

echo "[+] 全部流程执行完成！"
echo "[+] 所有结果已保存到: $OUTDIR"

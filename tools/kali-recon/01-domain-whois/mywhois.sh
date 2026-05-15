#!/bin/bash

# ==============================
# 域名基础信息收集脚本
# 用法: ./mywhois.sh example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./mywhois.sh 域名"
    echo "示例: ./mywhois.sh example.com"
    exit 1
fi

DOMAIN=$(echo "$1" | sed 's#https://##;s#http://##;s#/##g')
DIR="${DOMAIN}-domain-info"

mkdir -p "$DIR"

echo "[+] 目标域名: $DOMAIN"
echo "[+] 保存目录: $DIR"

if ! command -v whois >/dev/null 2>&1; then
    echo "[-] 未检测到 whois，请先安装:"
    echo "sudo apt install whois -y"
    exit 1
fi

if ! command -v dig >/dev/null 2>&1; then
    echo "[-] 未检测到 dig，请先安装:"
    echo "sudo apt install dnsutils -y"
    exit 1
fi

echo "[+] 1. 收集 WHOIS 信息..."
whois "$DOMAIN" > "$DIR/whois.txt" 2>&1

echo "[+] 2. 收集 DNS ANY 记录..."
dig "$DOMAIN" ANY > "$DIR/dns-any.txt" 2>&1

echo "[+] 3. 收集 A 记录..."
dig "$DOMAIN" A > "$DIR/dns-a.txt" 2>&1
dig "$DOMAIN" A > "$DIR/a_record.txt" 2>&1

echo "[+] 4. 收集 AAAA 记录..."
dig "$DOMAIN" AAAA > "$DIR/dns-aaaa.txt" 2>&1

echo "[+] 5. 收集 MX 记录..."
dig "$DOMAIN" MX > "$DIR/dns-mx.txt" 2>&1
dig "$DOMAIN" MX > "$DIR/mx_record.txt" 2>&1

echo "[+] 6. 收集 NS 记录..."
dig "$DOMAIN" NS > "$DIR/dns-ns.txt" 2>&1
dig "$DOMAIN" NS > "$DIR/ns_record.txt" 2>&1

echo "[+] 7. 收集 TXT 记录..."
dig "$DOMAIN" TXT > "$DIR/dns-txt.txt" 2>&1
dig "$DOMAIN" TXT > "$DIR/txt_record.txt" 2>&1

echo "[+] 8. nslookup 查询..."
nslookup "$DOMAIN" > "$DIR/nslookup.txt" 2>&1

echo "[+] 9. host 查询..."
host "$DOMAIN" > "$DIR/host.txt" 2>&1

echo "[+] 10. 提取 IP 地址..."
IP=$(dig +short "$DOMAIN" A | head -n 1)
if [ -n "$IP" ]; then
    echo "$IP" > "$DIR/ip.txt"
    echo "[+] 解析到 IP: $IP"

    echo "[+] 11. 查询 IP WHOIS..."
    whois "$IP" > "$DIR/ip_whois.txt" 2>&1
else
    echo "[-] 未解析到 IPv4 地址"
    touch "$DIR/ip.txt"
    touch "$DIR/ip_whois.txt"
fi

cat > "$DIR/summary.txt" << EOF
域名基础信息收集报告

目标: $DOMAIN
扫描时间: $(date)

生成文件:
- whois.txt          域名 WHOIS 信息
- dns-any.txt        DNS ANY 综合记录
- dns-a.txt          A 记录
- dns-aaaa.txt       AAAA 记录
- dns-mx.txt         MX 邮件记录
- dns-ns.txt         NS 域名服务器记录
- dns-txt.txt        TXT 记录
- nslookup.txt       nslookup 查询结果
- host.txt           host 查询结果
- ip.txt             解析到的 IPv4 地址
- ip_whois.txt       IP WHOIS 信息

重点查看:
- Registrar          注册商
- Creation Date      创建时间
- Expiry Date        过期时间
- Name Server        域名服务器
- Domain Status      域名状态
- A                  IPv4 地址
- MX                 邮件服务器
- TXT                SPF / DKIM / 验证信息
EOF

echo "[+] 收集完成！"
echo "[+] 结果保存在: $DIR"

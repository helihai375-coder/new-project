#!/bin/bash

# ==============================
# SSL 证书信息收集脚本
# 用法: ./myssl example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./myssl 域名"
    echo "示例: ./myssl example.com"
    echo "示例: ./myssl https://example.com"
    exit 1
fi

TARGET=$1

DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')
DIR="${DOMAIN}-ssl-info"

mkdir -p "$DIR"

echo "[+] 目标: $DOMAIN"
echo "[+] 保存目录: $DIR"

if ! command -v openssl >/dev/null 2>&1; then
    echo "[-] 未检测到 openssl，请先安装:"
    echo "sudo apt install openssl -y"
    exit 1
fi

echo "[+] 1. 获取原始 SSL 证书..."
echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null \
| openssl x509 -outform PEM > "$DIR/cert.pem" 2>/dev/null

if [ ! -s "$DIR/cert.pem" ]; then
    echo "[-] 未能获取 SSL 证书，目标可能没有开启 443 HTTPS"
    exit 1
fi

echo "[+] 2. 收集完整 SSL 证书信息..."
openssl x509 -in "$DIR/cert.pem" -text -noout > "$DIR/ssl_full.txt"

echo "[+] 3. 收集证书颁发者信息..."
openssl x509 -in "$DIR/cert.pem" -noout -issuer > "$DIR/ssl_issuer.txt"

echo "[+] 4. 收集证书主体信息..."
openssl x509 -in "$DIR/cert.pem" -noout -subject > "$DIR/ssl_subject.txt"

echo "[+] 5. 收集证书有效期..."
openssl x509 -in "$DIR/cert.pem" -noout -dates > "$DIR/ssl_dates.txt"

echo "[+] 6. 收集证书指纹..."
openssl x509 -in "$DIR/cert.pem" -noout -fingerprint -sha256 > "$DIR/ssl_fingerprint.txt"

echo "[+] 7. 提取 SAN 域名..."
openssl x509 -in "$DIR/cert.pem" -text -noout \
| grep -A1 "Subject Alternative Name" \
| tail -n 1 \
| sed 's/DNS://g;s/,/\n/g;s/ //g' \
| sort -u > "$DIR/san_domains.txt"

cat > "$DIR/summary.txt" << EOF
SSL 证书信息收集报告

目标: $DOMAIN
扫描时间: $(date)

生成文件:
- cert.pem               保存原始 PEM 格式 SSL 证书
- ssl_full.txt           保存完整 SSL 证书详细信息
- ssl_issuer.txt         保存证书颁发机构信息
- ssl_subject.txt        保存证书主体信息
- ssl_dates.txt          保存证书有效期信息
- ssl_fingerprint.txt    保存证书 SHA256 指纹信息
- san_domains.txt        保存证书中的 SAN 域名和可能的子域名

重点查看:
- Issuer                 证书颁发机构
- Subject                证书绑定主体
- Not Before             证书生效时间
- Not After              证书过期时间
- DNS                    证书绑定的域名或子域名
- Fingerprint            证书指纹，可用于证书识别
EOF

echo "[+] 收集完成！"
echo "[+] 结果保存在: $DIR"

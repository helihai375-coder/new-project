#!/bin/bash

# ==============================
# Recon 结果自动分析脚本
# 用法: ./analyze example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./analyze 域名"
    echo "示例: ./analyze example.com"
    exit 1
fi

DOMAIN=$(echo "$1" | sed 's#https://##;s#http://##;s#/##g')
RECON_DIR="${DOMAIN}-recon"
REPORT="$RECON_DIR/final_report.txt"

if [ ! -d "$RECON_DIR" ]; then
    echo "[-] 未找到目录: $RECON_DIR"
    echo "请先运行: ./recon $DOMAIN"
    exit 1
fi

echo "[+] 目标: $DOMAIN"
echo "[+] 分析目录: $RECON_DIR"
echo "[+] 生成报告: $REPORT"

DOMAIN_INFO="$RECON_DIR/${DOMAIN}-domain-info"
SUB_INFO="$RECON_DIR/${DOMAIN}-subdomain-info"
NMAP_INFO="$RECON_DIR/${DOMAIN}-nmap-info"
WHATWEB_INFO="$RECON_DIR/${DOMAIN}-whatweb-info"
HEADER_INFO="$RECON_DIR/${DOMAIN}-headers-info"
ROBOTS_INFO="$RECON_DIR/${DOMAIN}-robots-info"
SSL_INFO="$RECON_DIR/${DOMAIN}-ssl-info"
WAF_INFO="$RECON_DIR/${DOMAIN}-waf-info"
DIR_INFO="$RECON_DIR/${DOMAIN}-dir-info"
JS_INFO="$RECON_DIR/${DOMAIN}-js-info"
VULN_INFO="$RECON_DIR/${DOMAIN}-vuln-info"

cat > "$REPORT" << EOF
综合信息收集分析报告

目标: $DOMAIN
分析时间: $(date)

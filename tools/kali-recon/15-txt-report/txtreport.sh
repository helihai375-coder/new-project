#!/bin/bash

# ==============================
# TXT 报告导出脚本
# 用法: ./txtreport example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./txtreport 域名"
    echo "示例: ./txtreport example.com"
    exit 1
fi

DOMAIN=$(echo "$1" | sed 's#https://##;s#http://##;s#/##g')
RECON_DIR="${DOMAIN}-recon"
SOURCE_REPORT="$RECON_DIR/final_report.txt"
OUT_REPORT="$RECON_DIR/${DOMAIN}_report.txt"

if [ ! -d "$RECON_DIR" ]; then
    echo "[-] 未找到目录: $RECON_DIR"
    echo "请先运行: ./recon $DOMAIN"
    exit 1
fi

if [ ! -f "$SOURCE_REPORT" ]; then
    echo "[-] 未找到分析报告: $SOURCE_REPORT"
    echo "请先运行: ./analyze $DOMAIN"
    exit 1
fi

cp "$SOURCE_REPORT" "$OUT_REPORT"

echo "[+] TXT 报告导出完成！"
echo "[+] 文件位置: $OUT_REPORT"

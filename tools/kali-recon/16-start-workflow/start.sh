#!/bin/bash

# ==============================
# 一键信息收集 + 分析 + 报告生成脚本
# 用法: ./start example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./start 域名"
    echo "示例: ./start example.com"
    exit 1
fi

TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')

echo "[+] 目标: $DOMAIN"
echo "[+] 开始一键执行完整流程..."

if [ ! -x "./recon" ]; then
    echo "[-] 未找到或不可执行: ./recon"
    echo "请执行: chmod +x recon"
    exit 1
fi

if [ ! -x "./analyze" ]; then
    echo "[-] 未找到或不可执行: ./analyze"
    echo "请执行: chmod +x analyze"
    exit 1
fi

if [ ! -x "./report" ]; then
    echo "[-] 未找到或不可执行: ./report"
    echo "请执行: chmod +x report"
    exit 1
fi

echo "[+] 1. 执行信息收集..."
./recon "$DOMAIN"

echo "[+] 2. 执行结果分析..."
./analyze "$DOMAIN"

echo "[+] 3. 生成 HTML 报告..."
./report "$DOMAIN"

if [ -x "./txtreport" ]; then
    echo "[+] 4. 导出 TXT 报告..."
    ./txtreport "$DOMAIN"
fi

echo "[+] 全部完成！"
echo "[+] 最终目录: ${DOMAIN}-recon"
echo "[+] 文本报告: ${DOMAIN}-recon/final_report.txt"
echo "[+] HTML报告: ${DOMAIN}-recon/final_report.html"

if command -v xdg-open >/dev/null 2>&1; then
    echo "[+] 可使用以下命令打开报告:"
    echo "xdg-open ${DOMAIN}-recon/final_report.html"
else
    echo "[+] 可使用浏览器打开:"
    echo "${DOMAIN}-recon/final_report.html"
fi

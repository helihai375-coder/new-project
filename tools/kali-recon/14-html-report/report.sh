#!/bin/bash

# ==============================
# HTML 报告生成脚本
# 用法: ./report example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./report 域名"
    echo "示例: ./report example.com"
    exit 1
fi

DOMAIN=$(echo "$1" | sed 's#https://##;s#http://##;s#/##g')
RECON_DIR="${DOMAIN}-recon"
TXT_REPORT="$RECON_DIR/final_report.txt"
HTML_REPORT="$RECON_DIR/final_report.html"

if [ ! -d "$RECON_DIR" ]; then
    echo "[-] 未找到目录: $RECON_DIR"
    echo "请先运行: ./recon $DOMAIN"
    exit 1
fi

if [ ! -f "$TXT_REPORT" ]; then
    echo "[-] 未找到文本报告: $TXT_REPORT"
    echo "请先运行: ./analyze $DOMAIN"
    exit 1
fi

echo "[+] 目标: $DOMAIN"
echo "[+] 输入报告: $TXT_REPORT"
echo "[+] 输出报告: $HTML_REPORT"

ESCAPED_CONTENT=$(sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    "$TXT_REPORT")

cat > "$HTML_REPORT" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>${DOMAIN} 信息收集报告</title>
<style>
    body {
        margin: 0;
        padding: 0;
        background: #0f172a;
        color: #e5e7eb;
        font-family: Arial, "Microsoft YaHei", sans-serif;
    }

    .container {
        width: 90%;
        max-width: 1200px;
        margin: 40px auto;
        background: #111827;
        border-radius: 12px;
        box-shadow: 0 0 25px rgba(0,0,0,0.45);
        overflow: hidden;
    }

    .header {
        background: linear-gradient(135deg, #2563eb, #7c3aed);
        padding: 30px;
        text-align: center;
    }

    .header h1 {
        margin: 0;
        font-size: 32px;
        color: #ffffff;
    }

    .header p {
        margin-top: 10px;
        color: #dbeafe;
        font-size: 15px;
    }

    .meta {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
        padding: 20px 30px;
        background: #1f2937;
        border-bottom: 1px solid #374151;
    }

    .card {
        background: #0f172a;
        border: 1px solid #334155;
        border-radius: 10px;
        padding: 15px;
    }

    .card span {
        display: block;
        color: #93c5fd;
        font-size: 13px;
        margin-bottom: 6px;
    }

    .card strong {
        color: #f9fafb;
        font-size: 16px;
    }

    .content {
        padding: 30px;
    }

    pre {
        white-space: pre-wrap;
        word-wrap: break-word;
        line-height: 1.6;
        font-size: 14px;
        background: #020617;
        color: #e5e7eb;
        border: 1px solid #334155;
        border-radius: 10px;
        padding: 25px;
        overflow-x: auto;
    }

    .footer {
        text-align: center;
        padding: 20px;
        background: #1f2937;
        color: #9ca3af;
        font-size: 13px;
    }

    .tag {
        display: inline-block;
        padding: 4px 10px;
        margin-top: 8px;
        background: #1d4ed8;
        color: white;
        border-radius: 999px;
        font-size: 12px;
    }

    @media (max-width: 768px) {
        .meta {
            grid-template-columns: 1fr;
        }

        .header h1 {
            font-size: 24px;
        }
    }
</style>
</head>
<body>

<div class="container">

    <div class="header">
        <h1>${DOMAIN} 信息收集分析报告</h1>
        <p>Recon / Port / Web Fingerprint / Header / SSL / WAF / Directory / JS Analysis</p>
        <div class="tag">自动生成报告</div>
    </div>

    <div class="meta">
        <div class="card">
            <span>目标域名</span>
            <strong>${DOMAIN}</strong>
        </div>
        <div class="card">
            <span>报告时间</span>
            <strong>$(date "+%Y-%m-%d %H:%M:%S")</strong>
        </div>
        <div class="card">
            <span>报告文件</span>
            <strong>final_report.html</strong>
        </div>
    </div>

    <div class="content">
        <pre>${ESCAPED_CONTENT}</pre>
    </div>

    <div class="footer">
        本报告由本地信息收集脚本自动生成，仅用于授权安全测试、学习和防护分析。
    </div>

</div>

</body>
</html>
EOF

echo "[+] HTML 报告生成完成！"
echo "[+] 文件位置: $HTML_REPORT"
echo "[+] 使用浏览器打开:"
echo "firefox $HTML_REPORT"

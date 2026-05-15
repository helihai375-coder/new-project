#!/bin/bash

# ==============================
# JS 文件收集与接口提取脚本
# 用法: ./myjs example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./myjs 域名"
    echo "示例: ./myjs example.com"
    echo "示例: ./myjs https://example.com"
    exit 1
fi

TARGET=$1

DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')
DIR="${DOMAIN}-js-info"

mkdir -p "$DIR"

echo "[+] 目标: $DOMAIN"
echo "[+] 保存目录: $DIR"

if ! command -v curl >/dev/null 2>&1; then
    echo "[-] 未检测到 curl，请先安装:"
    echo "sudo apt install curl -y"
    exit 1
fi

echo "[+] 1. 获取首页 HTML..."
curl -s -L --max-time 20 "https://$DOMAIN" > "$DIR/index.html"

if [ ! -s "$DIR/index.html" ]; then
    echo "[-] HTTPS 首页获取失败，尝试 HTTP..."
    curl -s -L --max-time 20 "http://$DOMAIN" > "$DIR/index.html"
fi

echo "[+] 2. 提取 JS 文件链接..."
grep -Eo 'src="[^"]+\.js[^"]*"' "$DIR/index.html" \
| sed 's/src="//;s/"//' \
| sort -u > "$DIR/js_links_raw.txt"

echo "[+] 3. 处理 JS 完整链接..."
> "$DIR/js_links.txt"

while read -r JS; do
    if [[ "$JS" == http://* || "$JS" == https://* ]]; then
        echo "$JS" >> "$DIR/js_links.txt"
    elif [[ "$JS" == //* ]]; then
        echo "https:$JS" >> "$DIR/js_links.txt"
    elif [[ "$JS" == /* ]]; then
        echo "https://$DOMAIN$JS" >> "$DIR/js_links.txt"
    else
        echo "https://$DOMAIN/$JS" >> "$DIR/js_links.txt"
    fi
done < "$DIR/js_links_raw.txt"

sort -u "$DIR/js_links.txt" -o "$DIR/js_links.txt"

echo "[+] 4. 下载 JS 文件..."
mkdir -p "$DIR/js_files"

COUNT=1
while read -r URL; do
    echo "[+] 下载: $URL"
    curl -s -L --max-time 20 "$URL" -o "$DIR/js_files/js_$COUNT.js"
    COUNT=$((COUNT + 1))
done < "$DIR/js_links.txt"

echo "[+] 5. 从 JS 中提取 API / 路径..."
grep -RhoE '["'\''](/[a-zA-Z0-9_./?=&%-]+)["'\'']' "$DIR/js_files" 2>/dev/null \
| tr -d '"' \
| tr -d "'" \
| grep -E '^/' \
| sort -u > "$DIR/api_paths.txt"

echo "[+] 6. 提取可能的完整 URL..."
grep -RhoE 'https?://[a-zA-Z0-9./?=_:&%-]+' "$DIR/js_files" 2>/dev/null \
| sort -u > "$DIR/urls.txt"

echo "[+] 7. 提取可能的敏感关键词..."
grep -RniE 'api_key|apikey|token|secret|auth|bearer|password|passwd|access_key|client_id' "$DIR/js_files" 2>/dev/null \
> "$DIR/possible_sensitive_keywords.txt"

cat > "$DIR/summary.txt" << EOF
JS 文件收集与接口提取报告

目标: $DOMAIN
扫描时间: $(date)

生成文件:
- index.html                         保存网站首页 HTML 内容
- js_links_raw.txt                   保存原始 JS 文件链接
- js_links.txt                       保存处理后的完整 JS 文件链接
- js_files/                          保存下载到本地的 JS 文件
- api_paths.txt                      保存从 JS 中提取到的接口路径
- urls.txt                           保存从 JS 中提取到的完整 URL
- possible_sensitive_keywords.txt    保存可能包含敏感关键词的 JS 片段

重点查看:
- /api                               常见接口路径
- /admin                             常见后台路径
- /login                             常见登录接口
- token                              可能和认证有关
- api_key                            可能和接口密钥有关
- secret                             可能和密钥或配置有关
- client_id                          可能和 OAuth 或第三方登录有关
EOF

echo "[+] 收集完成！"
echo "[+] 结果保存在: $DIR"

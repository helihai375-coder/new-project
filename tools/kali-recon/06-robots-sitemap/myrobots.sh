#!/bin/bash

# ==============================
# robots.txt / sitemap.xml 收集脚本
# 用法: ./myrobots example.com
# ==============================

if [ -z "$1" ]; then
    echo "用法: ./myrobots 域名"
    echo "示例: ./myrobots example.com"
    echo "示例: ./myrobots https://example.com"
    exit 1
fi

TARGET=$1

DOMAIN=$(echo "$TARGET" | sed 's#https://##;s#http://##;s#/##g')
DIR="${DOMAIN}-robots-info"

mkdir -p "$DIR"

echo "[+] 目标: $DOMAIN"
echo "[+] 保存目录: $DIR"

if ! command -v curl >/dev/null 2>&1; then
    echo "[-] 未检测到 curl，请先安装:"
    echo "sudo apt install curl -y"
    exit 1
fi

echo "[+] 1. 收集 HTTP robots.txt..."
curl -s -L --max-time 15 "http://$DOMAIN/robots.txt" > "$DIR/http_robots.txt"

echo "[+] 2. 收集 HTTPS robots.txt..."
curl -s -L --max-time 15 "https://$DOMAIN/robots.txt" > "$DIR/https_robots.txt"

echo "[+] 3. 收集 HTTP sitemap.xml..."
curl -s -L --max-time 15 "http://$DOMAIN/sitemap.xml" > "$DIR/http_sitemap.xml"

echo "[+] 4. 收集 HTTPS sitemap.xml..."
curl -s -L --max-time 15 "https://$DOMAIN/sitemap.xml" > "$DIR/https_sitemap.xml"

echo "[+] 5. 提取 robots.txt 中的路径..."
cat "$DIR/http_robots.txt" "$DIR/https_robots.txt" 2>/dev/null \
| grep -Ei "Disallow:|Allow:" \
| awk '{print $2}' \
| sort -u > "$DIR/robots_paths.txt"

if grep -qi "<html" "$DIR/https_robots.txt"; then
    echo "[-] HTTPS robots.txt 返回的是 HTML 页面，可能不存在有效 robots.txt" > "$DIR/robots_check.txt"
else
    echo "[+] HTTPS robots.txt 可能有效，请查看 https_robots.txt" > "$DIR/robots_check.txt"
fi

cat > "$DIR/summary.txt" << EOF
robots.txt / sitemap.xml 收集报告

目标: $DOMAIN
扫描时间: $(date)

生成文件:
- http_robots.txt        保存 HTTP robots.txt 内容
- https_robots.txt       保存 HTTPS robots.txt 内容
- http_sitemap.xml       保存 HTTP sitemap.xml 内容
- https_sitemap.xml      保存 HTTPS sitemap.xml 内容
- robots_paths.txt       从 robots.txt 中提取出来的路径
- robots_check.txt       判断 robots.txt 是否可能有效

重点查看:
- Disallow               搜索引擎不允许访问的路径，可能包含后台或敏感目录
- Allow                  搜索引擎允许访问的路径
- Sitemap                网站地图地址，可能包含更多页面链接
- /admin                 常见后台路径
- /login                 常见登录路径
- /api                   常见接口路径
- /backup                常见备份路径
EOF

echo "[+] 收集完成！"
echo "[+] 结果保存在: $DIR"

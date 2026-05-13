#!/usr/bin/env bash
# 为指定文件夹创建带时间戳的 tar.gz 备份。

set -euo pipefail

SOURCE_DIR="${1:-}"
BACKUP_DIR="${2:-./backups}"

if [[ -z "$SOURCE_DIR" ]]; then
  echo "用法: $0 /path/to/source [backup-output-folder]"
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "源文件夹不存在: $SOURCE_DIR"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

NAME="$(basename "$SOURCE_DIR")"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT="$BACKUP_DIR/$NAME-$STAMP.tar.gz"

tar -czf "$OUTPUT" -C "$(dirname "$SOURCE_DIR")" "$NAME"

echo "备份已创建: $OUTPUT"

#!/usr/bin/env bash
# Create a timestamped tar.gz backup of a folder.

set -euo pipefail

SOURCE_DIR="${1:-}"
BACKUP_DIR="${2:-./backups}"

if [[ -z "$SOURCE_DIR" ]]; then
  echo "Usage: $0 /path/to/source [backup-output-folder]"
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source folder does not exist: $SOURCE_DIR"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

NAME="$(basename "$SOURCE_DIR")"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT="$BACKUP_DIR/$NAME-$STAMP.tar.gz"

tar -czf "$OUTPUT" -C "$(dirname "$SOURCE_DIR")" "$NAME"

echo "Backup created: $OUTPUT"


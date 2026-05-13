#!/usr/bin/env bash
# Show listening TCP and UDP ports.

set -euo pipefail

if command -v ss >/dev/null 2>&1; then
  ss -tulpen
else
  netstat -tulpen
fi


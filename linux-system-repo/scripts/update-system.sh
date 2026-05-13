#!/usr/bin/env bash
# Update common Debian/Ubuntu/Kali based Linux systems.

set -euo pipefail

if ! command -v apt >/dev/null 2>&1; then
  echo "This script expects an apt-based Linux system."
  exit 1
fi

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

echo "System update completed."


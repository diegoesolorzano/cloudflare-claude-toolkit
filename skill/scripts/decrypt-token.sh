#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
gpg --quiet --decrypt "$SCRIPT_DIR/../secrets/meta-token.gpg" 2>/dev/null

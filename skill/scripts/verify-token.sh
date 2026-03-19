#!/usr/bin/env bash
set -euo pipefail

TOKEN="${1:?Usage: verify-token.sh <token>}"

curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $TOKEN"

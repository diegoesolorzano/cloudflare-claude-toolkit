#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

META_TOKEN=$("$SCRIPT_DIR/decrypt-token.sh")

# Detect account ID from the meta-token
ACCOUNT_ID=$(curl -s "https://api.cloudflare.com/client/v4/accounts" \
  -H "Authorization: Bearer $META_TOKEN" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('success') and data['result']:
    print(data['result'][0]['id'])
else:
    sys.exit(1)
" 2>/dev/null)

if [[ -z "$ACCOUNT_ID" ]]; then
  echo '{"success":false,"errors":[{"message":"Could not detect account ID. Check your meta-token."}]}' >&2
  exit 1
fi

curl -s "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tokens" \
  -H "Authorization: Bearer $META_TOKEN" \
  -H "Content-Type: application/json"

#!/usr/bin/env bash
set -euo pipefail

TOKEN_ID="${1:?Usage: revoke-token.sh <token-id> [account-id]}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

META_TOKEN=$("$SCRIPT_DIR/decrypt-token.sh")

ACCOUNT_ID_PARAM="${2:-}"

# Use provided Account ID or detect from the meta-token
if [[ -n "$ACCOUNT_ID_PARAM" ]]; then
  ACCOUNT_ID="$ACCOUNT_ID_PARAM"
else
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
  
  if [[ -n "$ACCOUNT_ID" ]]; then
    echo "Notice: Using first available Account ID: $ACCOUNT_ID" >&2
    echo "To use a specific account, pass <account-id> as the second argument" >&2
  fi
fi

if [[ -z "$ACCOUNT_ID" ]]; then
  echo '{"success":false,"errors":[{"message":"Could not detect account ID. Check your meta-token."}]}' >&2
  exit 1
fi

curl -s -X DELETE \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tokens/$TOKEN_ID" \
  -H "Authorization: Bearer $META_TOKEN"

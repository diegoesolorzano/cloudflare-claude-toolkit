#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

NAME=""
POLICIES=""
ACCOUNT_ID_PARAM=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --name) NAME="$2"; shift 2;;
    --policies) POLICIES="$2"; shift 2;;
    --account-id) ACCOUNT_ID_PARAM="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

if [[ -z "$NAME" || -z "$POLICIES" ]]; then
  echo "Usage: create-token.sh --name <name> --policies '<json>'" >&2
  exit 1
fi

META_TOKEN=$("$SCRIPT_DIR/decrypt-token.sh")

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
    echo "To use a specific account, pass --account-id <id>" >&2
  fi
fi

if [[ -z "$ACCOUNT_ID" ]]; then
  echo '{"success":false,"errors":[{"message":"Could not detect account ID. Check your meta-token."}]}' >&2
  exit 1
fi

BODY=$(python3 -c '
import sys, json
try:
    print(json.dumps({"name": sys.argv[1], "policies": json.loads(sys.argv[2])}))
except Exception as e:
    print("Error parsing JSON: {}".format(e), file=sys.stderr)
    sys.exit(1)
' "$NAME" "$POLICIES")

curl -s -X POST \
  "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/tokens" \
  -H "Authorization: Bearer $META_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY"

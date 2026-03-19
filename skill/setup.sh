#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SECRETS_DIR="$SCRIPT_DIR/secrets"

echo "=== Cloudflare Meta-Token Setup ==="
echo ""
echo "This script encrypts your Cloudflare Account API Token with GPG."
echo "The token must have 'Create Additional Tokens' permissions."
echo ""

# Check GPG
if ! command -v gpg &>/dev/null; then
  echo "GPG is not installed. Install it first:"
  echo "  macOS:  brew install gnupg"
  echo "  Ubuntu: sudo apt install gnupg"
  exit 1
fi

# List available GPG keys
echo "Available GPG keys:"
echo ""
gpg --list-keys --keyid-format long 2>/dev/null | grep -A1 "^pub" || {
  echo "No GPG keys found. Generate one first:"
  echo "  gpg --full-generate-key"
  exit 1
}
echo ""

# Get recipient
read -rp "GPG key email or ID to encrypt for: " GPG_RECIPIENT

if [[ -z "$GPG_RECIPIENT" ]]; then
  echo "No recipient specified." >&2
  exit 1
fi

# Get token
read -rsp "Paste your Cloudflare meta-token: " META_TOKEN
echo ""

if [[ -z "$META_TOKEN" ]]; then
  echo "No token provided." >&2
  exit 1
fi

# Encrypt
mkdir -p "$SECRETS_DIR"
printf "%s" "$META_TOKEN" | gpg --encrypt --recipient "$GPG_RECIPIENT" --trust-model always -o "$SECRETS_DIR/meta-token.gpg"

# Verify
echo ""
echo "Verifying decryption..."
DECRYPTED=$(gpg --quiet --decrypt "$SECRETS_DIR/meta-token.gpg" 2>/dev/null) || {
  echo "Decryption failed. Check your GPG key." >&2
  exit 1
}

echo "Verifying token against Cloudflare API..."
RESULT=$(curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $DECRYPTED")

SUCCESS=$(echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('success','false'))" 2>/dev/null)

if [[ "$SUCCESS" == "True" ]]; then
  echo "Token verified successfully."
else
  echo "Warning: Token verification failed. The token may be invalid or lack permissions."
  echo "Response: $RESULT"
fi

echo ""
echo "Setup complete. Meta-token encrypted at: $SECRETS_DIR/meta-token.gpg"
echo ""
echo "To add more GPG recipients (team members), re-encrypt:"
echo "  gpg --decrypt secrets/meta-token.gpg | gpg --encrypt --recipient you@team.com --recipient them@team.com -o secrets/meta-token.gpg"

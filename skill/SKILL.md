---
name: cf-token
description: Managing Cloudflare Account API tokens — create scoped tokens, list existing tokens, verify tokens, and revoke tokens. Uses a GPG-encrypted meta-token that never enters Claude's context. Use when user needs a new Cloudflare API token, wants to check existing tokens, or says "cf token", "cloudflare token", "create token for workers/r2/dns".
allowed-tools: Bash, Read
---

# Cloudflare Token Manager

Create, list, verify, and revoke Cloudflare Account API tokens using a GPG-encrypted meta-token. The meta-token never passes through Claude's context — scripts handle decryption internally.

## Prerequisites

- GPG key that can decrypt `secrets/meta-token.gpg`
- Run `setup.sh` if you haven't encrypted your meta-token yet

## Scripts

All scripts live in `scripts/` relative to this skill's directory. Resolve the path dynamically:

```bash
SKILL_DIR="$(dirname "$(find ~/.claude/skills/cf-token -name SKILL.md)")"
```

| Script | Purpose | Args |
|--------|---------|------|
| `create-token.sh` | Create a scoped token | `--name <name> --policies '<json>'` |
| `list-tokens.sh` | List all account tokens | (none) |
| `verify-token.sh` | Test if a token works | `<token>` |
| `revoke-token.sh` | Delete a token by ID | `<token-id>` |

## Procedure

### Creating a token

1. Ask the user what the token is for (Workers, R2, DNS, etc.)
2. Build the policies JSON based on the Cloudflare API permissions
3. Run: `$SKILL_DIR/scripts/create-token.sh --name "<descriptive-name>" --policies '<json>'`
4. Parse the response — show the user ONLY the new token value and its ID
5. Remind: save the token securely, it won't be shown again

### Listing tokens

1. Run: `$SKILL_DIR/scripts/list-tokens.sh`
2. Parse and show a clean table: name, id, status, last used, expires

### Verifying a token

1. Run: `$SKILL_DIR/scripts/verify-token.sh <token>`
2. Show status and token details

### Revoking a token

1. Confirm with user before revoking
2. Run: `$SKILL_DIR/scripts/revoke-token.sh <token-id>`
3. Confirm deletion

## Security Rules

- NEVER output or log the meta-token
- NEVER read `secrets/meta-token.gpg` directly — only scripts access it
- Only show scoped tokens returned by the API
- If GPG decryption fails, tell the user to check their GPG key or run setup.sh

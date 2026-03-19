# Cloudflare Account Management

## MCP Servers

- **Global** (`cloudflare-api`): Primary account — available in all projects
- **Per-project** (`--scope local`): Client/secondary accounts — only in that project

To add a client account to a project:
```bash
claude mcp add --transport http --scope local cloudflare-api https://mcp.cloudflare.com/mcp
```

## Token Management

The skill `/cf-token` manages Account API Tokens using a GPG-encrypted meta-token (`~/.claude/skills/cf-token/secrets/meta-token.gpg`). Only applies to the primary account.

For project tokens, store in `secrets/` (protected by git-crypt) or `.env`.

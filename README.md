# Cloudflare Claude Toolkit

A complete toolkit for managing Cloudflare resources from [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) using the official Cloudflare MCP server and a GPG-secured token management skill.

## What's Included

| Component | Purpose |
|-----------|---------|
| **MCP Setup** | Connect Claude Code to the Cloudflare API (all services) |
| **`/cf-token` Skill** | Create, list, verify, and revoke API tokens securely |
| **Multi-account Rule** | Manage multiple Cloudflare accounts per project |
| **GPG Guide** | Set up GPG encryption for team token sharing |

## Quick Start

### 1. Install the Cloudflare MCP Server

The [official Cloudflare MCP server](https://github.com/cloudflare/mcp) gives Claude Code access to the entire Cloudflare API (Workers, R2, D1, DNS, Pages, KV, and more) via two tools: `search` and `execute`.

```bash
# Global (your main account — available in all projects)
claude mcp add --transport http --scope user cloudflare-api https://mcp.cloudflare.com/mcp
```

First use will open your browser for OAuth authentication.

For details, see [docs/mcp-setup.md](docs/mcp-setup.md).

### 2. Install the `/cf-token` Skill (Optional)

If you have a Cloudflare [Account API Token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) with "Create Additional Tokens" permissions (a "meta-token"), you can manage tokens directly from Claude Code without leaving your terminal.

```bash
# Copy skill to your Claude Code skills directory
cp -r skill/ ~/.claude/skills/cf-token/

# Run the setup script to encrypt your meta-token with GPG
~/.claude/skills/cf-token/setup.sh
```

The meta-token is encrypted with your GPG key and **never enters Claude's context** — scripts handle decryption internally.

For details, see [docs/gpg-setup.md](docs/gpg-setup.md).

### 3. Multi-Account Setup (Optional)

If you work with multiple Cloudflare accounts (personal + clients), you can scope MCP servers per project:

```bash
# In a client project — uses the client's Cloudflare account
cd ~/projects/client-x
claude mcp add --transport http --scope local cloudflare-api https://mcp.cloudflare.com/mcp
```

Copy the example rule to your Claude Code rules:

```bash
cp rules/cloudflare-accounts.md ~/.claude/rules/
```

Edit it with your account details. See [docs/multi-account.md](docs/multi-account.md).

## Architecture

```
You (Claude Code)
  │
  ├─ MCP Server (mcp.cloudflare.com) ← OAuth per account
  │    └─ search() + execute() → entire Cloudflare API
  │
  └─ /cf-token skill ← GPG-encrypted meta-token
       └─ scripts/ → create, list, verify, revoke tokens
            └─ meta-token never in Claude's context
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview)
- GPG (for the `/cf-token` skill) — `brew install gnupg` on macOS
- A Cloudflare account

## Security

- The meta-token is GPG-encrypted at rest (`secrets/meta-token.gpg`)
- Scripts decrypt internally — Claude never sees the meta-token
- OAuth sessions are per-account, per-MCP-server
- For teams: each member encrypts the token with their GPG key, or re-encrypt for multiple recipients

## License

MIT

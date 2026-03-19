# Multi-Account Setup

If you manage multiple Cloudflare accounts (personal, company, clients), you can scope MCP servers to specific projects.

## Strategy

| Scope | Account | Available |
|-------|---------|-----------|
| `--scope user` (global) | Your primary account | All projects |
| `--scope local` (project) | Client/specific account | Only that project |

## Setup

### 1. Global (primary account)

```bash
claude mcp add --transport http --scope user cloudflare-api https://mcp.cloudflare.com/mcp
```

### 2. Per-project (client account)

```bash
cd ~/projects/client-x
claude mcp add --transport http --scope local cloudflare-api https://mcp.cloudflare.com/mcp
```

When you authenticate, use the client's Cloudflare credentials. The local MCP overrides the global one for that project.

## Rule Template

Copy `rules/cloudflare-accounts.md` to `~/.claude/rules/` and edit with your account details:

```bash
cp rules/cloudflare-accounts.md ~/.claude/rules/
```

This rule loads in every session, reminding Claude which account context to use.

## Tips

- Local scope **overrides** global for the same MCP server name
- Each OAuth session is independent — different accounts per project
- Use descriptive project directories so it's clear which account applies

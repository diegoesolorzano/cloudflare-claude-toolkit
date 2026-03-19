# Cloudflare MCP Server Setup

The [official Cloudflare MCP server](https://github.com/cloudflare/mcp) gives Claude Code access to the entire Cloudflare API through two tools:

| Tool | Purpose |
|------|---------|
| `search` | Find API endpoints by description |
| `execute` | Call any Cloudflare API endpoint |

This covers Workers, R2, D1, DNS, Pages, KV, Firewall, Load Balancers, Stream, Images, AI Gateway, Vectorize, Access, and more.

## Install

```bash
claude mcp add --transport http --scope user cloudflare-api https://mcp.cloudflare.com/mcp
```

- `--scope user` makes it available in all projects
- `--scope local` limits it to the current project

## Authentication

First use opens your browser for OAuth. You'll authorize Claude Code to access your Cloudflare account with the permissions you select.

Each MCP server entry maintains its own OAuth session — useful for [multi-account setups](multi-account.md).

## Usage Examples

Once installed, you can ask Claude Code:

- "Create an R2 bucket called my-assets"
- "Add a DNS A record for api.example.com pointing to 1.2.3.4"
- "List my Workers"
- "Show D1 databases"
- "Create a new KV namespace"

Claude uses `search` to find the right endpoint, then `execute` to call it.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| OAuth popup doesn't appear | Check browser default, try again |
| "Unauthorized" errors | Re-authenticate: remove and re-add the MCP server |
| Wrong account | Check [multi-account setup](multi-account.md) |

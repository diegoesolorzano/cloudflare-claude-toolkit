# GPG Setup for Token Encryption

The `/cf-token` skill uses GPG to encrypt your Cloudflare meta-token at rest. This guide covers setup for individuals and teams.

## Individual Setup

### 1. Install GPG

```bash
# macOS
brew install gnupg pinentry-mac

# Ubuntu/Debian
sudo apt install gnupg
```

### 2. Generate a key (if you don't have one)

```bash
gpg --full-generate-key
```

Choose RSA 3072+ bits, set an expiration, and add your email.

### 3. Configure pinentry (macOS)

For GPG to work from non-interactive shells (like Claude Code), configure pinentry-mac:

```bash
echo 'pinentry-program /opt/homebrew/bin/pinentry-mac' >> ~/.gnupg/gpg-agent.conf
echo 'allow-loopback-pinentry' >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
```

This opens a native macOS dialog for the passphrase instead of requiring a TTY.

### 4. Run setup

```bash
~/.claude/skills/cf-token/setup.sh
```

## Team Setup

### Adding team members

Each member needs:
1. Their own GPG key
2. To share their **public** key with the person who manages the encrypted token

### Re-encrypt for multiple recipients

```bash
# Decrypt with your key, re-encrypt for the team
gpg --quiet --decrypt secrets/meta-token.gpg | \
  gpg --encrypt \
    --recipient alice@team.com \
    --recipient bob@team.com \
    --recipient diego@team.com \
    -o secrets/meta-token.gpg
```

### Removing a team member

1. Re-encrypt **without** their recipient
2. **Rotate the meta-token** in Cloudflare (the removed member still knows the old token)

### Sharing the skill

Copy the entire `skill/` directory to each member's `~/.claude/skills/cf-token/`. The `secrets/meta-token.gpg` file is safe to share — only authorized GPG keys can decrypt it.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Inappropriate ioctl for device` | Configure pinentry-mac (step 3 above) |
| `No secret key` | Your GPG key can't decrypt — re-encrypt with your key |
| `public key decryption failed` | Wrong passphrase or key not available |

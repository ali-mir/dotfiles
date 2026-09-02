#!/usr/bin/env bash
# Sets up FireConnect for Claude Code, giving access to Fireworks-hosted models
# (DeepSeek, GLM, Kimi, Qwen) alongside the standard Anthropic models.
#
# Called from scripts/setup.sh during work-linux profile setup.
# Interactive: prompts for a Fireworks API key (paste it from
#   https://app.fireworks.ai/settings/users/api-keys).
#
# Note on the API key: fireconnect writes it into ~/.claude/settings.json as
# ANTHROPIC_CUSTOM_HEADERS, alongside ANTHROPIC_BASE_URL. Those two must live in
# the same file — splitting the key into ~/.claude/settings.local.json does not
# work, because a user-level settings.local.json is not read as a settings
# source, so the base URL points at Fireworks while the key never arrives and
# every request 401s. That is why ~/.claude/settings.json is gitignored and
# seeded from settings.template.json rather than symlinked into the repo.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER_URL="https://gist.github.com/RedBeard0531/87f63f7e5b073dd26a20ef24ef648248/raw"

# nvm lazy-loads in interactive shells, so node is often not on PATH in a
# script. Resolve it explicitly.
resolve_node() {
  local node_bin
  node_bin="$(command -v node 2>/dev/null || true)"
  if [[ -z "$node_bin" ]]; then
    node_bin="$(echo "$HOME"/.nvm/versions/node/*/bin/node 2>/dev/null | tr ' ' '\n' | tail -1)"
  fi
  if [[ -z "$node_bin" || ! -x "$node_bin" ]]; then
    echo "  Node.js not found; install Node 18+ and rerun setup" >&2
    return 1
  fi
  echo "$node_bin"
}

# Skip if fireconnect is already installed and authenticated.
if command -v fireconnect &>/dev/null && fireconnect status --json &>/dev/null 2>&1; then
  echo "  FireConnect already configured, skipping"
  exit 0
fi

NODE_BIN="$(resolve_node)"
PATH="$(dirname "$NODE_BIN"):$PATH"
export PATH

echo "  Running FireConnect installer (you'll be prompted for an API key)..."
bash <(curl -fsSL "$INSTALLER_URL")

# Guard: the live settings file must never be tracked, since it now holds the
# API key. Fail loudly rather than let a key reach the index.
if git -C "$DOTFILES_DIR" ls-files --error-unmatch \
     work/linux/claude/settings.json &>/dev/null; then
  echo "  WARNING: work/linux/claude/settings.json is tracked but contains your" >&2
  echo "  API key. Run: git rm --cached work/linux/claude/settings.json" >&2
fi

echo "  FireConnect setup complete — restart Claude Code, then run /model to pick a model"

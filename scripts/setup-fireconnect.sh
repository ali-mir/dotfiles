#!/usr/bin/env bash
# Sets up FireConnect for Claude Code, giving access to Fireworks-hosted models
# (DeepSeek, GLM, Kimi, Qwen) alongside the standard Anthropic models.
#
# Called from scripts/setup.sh during work-linux profile setup.
# Interactive: prompts for a Fireworks API key (paste it from
#   https://app.fireworks.ai/settings/users/api-keys).
#
# After the installer runs, this script:
#   1. Restores the ~/.claude/settings.json symlink (the installer replaces it
#      with a regular file)
#   2. Moves the API key out of the git-tracked settings.json into untracked
#      ~/.claude/settings.local.json so it never gets committed
#   3. Pins the default model to the explicit Anthropic entry, since the
#      installer remaps the bare 'fable' tier alias to kimi-k3

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TRACKED_SETTINGS="$DOTFILES_DIR/work/linux/claude/settings.json"
LIVE_SETTINGS="$HOME/.claude/settings.json"
LOCAL_SETTINGS="$HOME/.claude/settings.local.json"
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
export PATH="$(dirname "$NODE_BIN"):$PATH"

echo "  Running FireConnect installer (you'll be prompted for an API key)..."
bash <(curl -fsSL "$INSTALLER_URL")

# --- Post-install cleanup ---

# 1. The installer replaces the symlink with a regular file. Move the content
#    back into the dotfiles repo and re-create the symlink.
if [[ ! -L "$LIVE_SETTINGS" ]]; then
  mv "$LIVE_SETTINGS" "$TRACKED_SETTINGS"
  ln -sf "$TRACKED_SETTINGS" "$LIVE_SETTINGS"
  echo "  Restored settings.json symlink into dotfiles"
fi

# 2. Move the API key from the tracked file to untracked settings.local.json.
# 3. Pin the default model to the explicit Anthropic entry.
"$NODE_BIN" -e '
const fs = require("node:fs");
const tracked = process.argv[1];
const local = process.argv[2];

const s = JSON.parse(fs.readFileSync(tracked, "utf8"));

// Move API key to settings.local.json
const key = s.env && s.env.ANTHROPIC_CUSTOM_HEADERS;
if (key) {
  delete s.env.ANTHROPIC_CUSTOM_HEADERS;
  let l = {};
  try { l = JSON.parse(fs.readFileSync(local, "utf8")); } catch (e) {
    if (e.code !== "ENOENT") throw e;
  }
  l.env = l.env || {};
  l.env.ANTHROPIC_CUSTOM_HEADERS = key;
  fs.writeFileSync(local, JSON.stringify(l, null, 2) + "\n");
  console.log("  Moved API key to settings.local.json (untracked)");
}

// Pin default to explicit Anthropic model (not the remapped tier alias)
s.model = "claude-fable-5-1[1m]";
fs.writeFileSync(tracked, JSON.stringify(s, null, 2) + "\n");
console.log("  Pinned default model to claude-fable-5-1[1m]");
' "$TRACKED_SETTINGS" "$LOCAL_SETTINGS"

echo "  FireConnect setup complete — restart Claude Code, then run /model to pick a model"

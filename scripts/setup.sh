#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMON_DIR="$DOTFILES_DIR/common"

usage() {
  echo "Usage: $0 [personal|work]"
  exit 1
}

PROFILE="${1:-}"
if [[ "$PROFILE" != "personal" && "$PROFILE" != "work" ]]; then
  usage
fi

PROFILE_DIR="$DOTFILES_DIR/$PROFILE"

backup_and_link() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "  Backing up $dest → $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  ln -sf "$src" "$dest"
  echo "  Linked $dest → $src"
}

echo "Setting up $PROFILE machine dotfiles from $DOTFILES_DIR"
echo

backup_and_link "$PROFILE_DIR/.zshrc"            "$HOME/.zshrc"
backup_and_link "$COMMON_DIR/.gitconfig"            "$HOME/.gitconfig"
backup_and_link "$PROFILE_DIR/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
backup_and_link "$COMMON_DIR/ghostty/config"      "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# Claude Code settings
backup_and_link "$PROFILE_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# Claude Desktop config
backup_and_link "$PROFILE_DIR/claude/claude_desktop_config.json" "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# VSCode extensions
EXTENSIONS_FILE="$PROFILE_DIR/vscode/extensions.txt"
if [[ -s "$EXTENSIONS_FILE" ]]; then
  echo
  echo "Installing VSCode extensions..."
  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    code --install-extension "$ext" --force 2>/dev/null && echo "  Installed $ext" || echo "  Failed to install $ext"
  done < "$EXTENSIONS_FILE"
else
  echo
  echo "  Skipping VSCode extensions (empty extensions.txt)"
fi

echo
echo "Done. Verify with:"
echo "  ls -la ~/.zshrc ~/.gitconfig"
echo "  ls -la ~/Library/Application\ Support/com.mitchellh.ghostty/config"
echo "  ls -la ~/Library/Application\ Support/Code/User/settings.json"
echo "  ls -la ~/.claude/settings.json"
echo "  ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.json"

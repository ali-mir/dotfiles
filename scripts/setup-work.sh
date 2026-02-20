#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_DIR="$DOTFILES_DIR/work"
COMMON_DIR="$DOTFILES_DIR/common"

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

echo "Setting up work machine dotfiles from $DOTFILES_DIR"
echo

backup_and_link "$PROFILE_DIR/.zshrc"                                             "$HOME/.zshrc"
backup_and_link "$PROFILE_DIR/.gitconfig"                                          "$HOME/.gitconfig"
backup_and_link "$PROFILE_DIR/vscode/settings.json"                               "$HOME/Library/Application Support/Code/User/settings.json"
backup_and_link "$COMMON_DIR/ghostty/config"                                       "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

echo
echo "Done. Verify with: ls -la ~/.zshrc ~/.gitconfig \"$HOME/Library/Application Support/com.mitchellh.ghostty/config\""

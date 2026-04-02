#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMON_DIR="$DOTFILES_DIR/common"
OS="$(uname -s)"

usage() {
  echo "Usage: $0 [personal|work-macos|work-linux]"
  exit 1
}

PROFILE="${1:-}"
case "$PROFILE" in
  personal|work-macos)
    if [[ "$OS" != "Darwin" ]]; then
      echo "Error: '$PROFILE' can only be run on macOS (detected: $OS)"
      exit 1
    fi
    ;;
  work-linux)
    if [[ "$OS" != "Linux" ]]; then
      echo "Error: '$PROFILE' can only be run on Linux (detected: $OS)"
      exit 1
    fi
    ;;
  *)
    usage
    ;;
esac

case "$PROFILE" in
  personal)    PROFILE_DIR="$DOTFILES_DIR/personal" ;;
  work-macos)  PROFILE_DIR="$DOTFILES_DIR/work/macos" ;;
  work-linux)  PROFILE_DIR="$DOTFILES_DIR/work/linux" ;;
esac

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

echo "Setting up $PROFILE dotfiles from $DOTFILES_DIR"
echo

# --- Common setup (all profiles) ---

# oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "  oh-my-zsh already installed, skipping"
fi
echo

# powerline font for agnoster
if fc-list 2>/dev/null | grep -qi "for Powerline"; then
  echo "  Powerline fonts already installed, skipping"
else
  echo "Installing Powerline fonts..."
  git clone https://github.com/powerline/fonts.git --depth=1 /tmp/powerline-fonts
  /tmp/powerline-fonts/install.sh
  rm -rf /tmp/powerline-fonts
fi
echo

# common symlinks
backup_and_link "$COMMON_DIR/zsh-themes/agnoster-custom.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/agnoster-custom.zsh-theme"
backup_and_link "$COMMON_DIR/.gitconfig"   "$HOME/.gitconfig"
backup_and_link "$COMMON_DIR/git/ignore"   "$HOME/.config/git/ignore"

# profile-specific .zshrc
backup_and_link "$PROFILE_DIR/.zshrc" "$HOME/.zshrc"

# Claude Code settings
backup_and_link "$PROFILE_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# --- macOS-only setup ---
if [[ "$OS" == "Darwin" ]]; then
  # homebrew
  if command -v brew &>/dev/null; then
    echo "  Homebrew already installed, updating..."
    brew update
  else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo

  # age for encrypted backups
  if ! command -v age &>/dev/null; then
    echo "Installing age..."
    brew install age
  fi
  echo

  # SSH config
  if [[ -f "$PROFILE_DIR/ssh/config" ]]; then
    backup_and_link "$PROFILE_DIR/ssh/config" "$HOME/.ssh/config"
  fi

  # VS Code
  backup_and_link "$PROFILE_DIR/vscode/settings.json"    "$HOME/Library/Application Support/Code/User/settings.json"
  backup_and_link "$PROFILE_DIR/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

  # Ghostty
  backup_and_link "$COMMON_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

  # Claude Desktop
  backup_and_link "$PROFILE_DIR/claude/claude_desktop_config.json" "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

  # VSCode extensions
  EXTENSIONS_FILE="$PROFILE_DIR/vscode/extensions.txt"
  if ! command -v code &>/dev/null; then
    VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    if [[ -f "$VSCODE_BIN" ]]; then
      echo
      echo "  Linking 'code' CLI to /usr/local/bin/code..."
      ln -sf "$VSCODE_BIN" /usr/local/bin/code
    else
      echo
      echo "  Skipping VSCode extensions (VSCode not installed and no 'code' CLI found)"
    fi
  fi
  if command -v code &>/dev/null && [[ -s "$EXTENSIONS_FILE" ]]; then
    echo
    echo "Installing VSCode extensions..."
    while IFS= read -r ext; do
      [[ -z "$ext" ]] && continue
      code --install-extension "$ext" --force 2>/dev/null && echo "  Installed $ext" || echo "  Failed to install $ext"
    done < "$EXTENSIONS_FILE"
  else
    echo
    echo "  Skipping VSCode extensions (empty extensions.txt or no 'code' CLI)"
  fi
fi

# --- Linux-only setup ---
if [[ "$OS" == "Linux" ]]; then
  backup_and_link "$PROFILE_DIR/.tmux.conf"   "$HOME/.tmux.conf"
  backup_and_link "$PROFILE_DIR/.workstreams"  "$HOME/.workstreams"

  # ws-* workstream scripts
  for script in ws ws-new ws-kill ws-list; do
    backup_and_link "$PROFILE_DIR/bin/$script" "$HOME/bin/$script"
    chmod +x "$HOME/bin/$script"
  done
fi

echo
echo "Done. Verify with:"
echo "  ls -la ~/.zshrc ~/.gitconfig ~/.config/git/ignore ~/.claude/settings.json"
if [[ "$OS" == "Darwin" ]]; then
  echo "  ls -la ~/Library/Application\ Support/com.mitchellh.ghostty/config"
  echo "  ls -la ~/Library/Application\ Support/Code/User/settings.json"
  echo "  ls -la ~/Library/Application\ Support/Code/User/keybindings.json"
  echo "  ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.json"
  echo "  ls -la ~/.ssh/config"
elif [[ "$OS" == "Linux" ]]; then
  echo "  ls -la ~/.tmux.conf ~/.workstreams"
  echo "  ls -la ~/bin/ws ~/bin/ws-new ~/bin/ws-kill ~/bin/ws-list"
fi

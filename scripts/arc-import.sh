#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARC_DIR="$DOTFILES_DIR/work/arc"

ARC_SUPPORT="$HOME/Library/Application Support/Arc"
ARC_PLIST_DOMAIN="company.thebrowser.Browser"

if [[ ! -d "$ARC_DIR" ]]; then
  echo "Error: $ARC_DIR not found. Run arc-export.sh first."
  exit 1
fi

# Check if Arc is running
if pgrep -xq "Arc"; then
  echo "Error: Arc is running. Please quit Arc before importing."
  echo "  You can quit Arc with: osascript -e 'tell application \"Arc\" to quit'"
  exit 1
fi

echo "Importing Arc browser settings from $ARC_DIR"
echo

# Import preferences
if [[ -f "$ARC_DIR/preferences.plist" ]]; then
  echo "  Importing preferences..."
  if [[ -f "$HOME/Library/Preferences/$ARC_PLIST_DOMAIN.plist" ]]; then
    cp "$HOME/Library/Preferences/$ARC_PLIST_DOMAIN.plist" \
       "$HOME/Library/Preferences/$ARC_PLIST_DOMAIN.plist.bak"
    echo "  Backed up existing preferences → $ARC_PLIST_DOMAIN.plist.bak"
  fi
  defaults import "$ARC_PLIST_DOMAIN" "$ARC_DIR/preferences.plist"
  echo "  ✓ Preferences imported"
else
  echo "  ⚠ preferences.plist not found, skipping"
fi

# Import sidebar (spaces, pinned tabs, folders, links)
if [[ -f "$ARC_DIR/StorableSidebar.json" ]]; then
  echo "  Importing sidebar (spaces, tabs, links)..."
  mkdir -p "$ARC_SUPPORT"
  if [[ -f "$ARC_SUPPORT/StorableSidebar.json" ]]; then
    cp "$ARC_SUPPORT/StorableSidebar.json" \
       "$ARC_SUPPORT/StorableSidebar.json.bak"
    echo "  Backed up existing sidebar → StorableSidebar.json.bak"
  fi
  cp "$ARC_DIR/StorableSidebar.json" "$ARC_SUPPORT/StorableSidebar.json"
  echo "  ✓ Sidebar imported"
else
  echo "  ⚠ StorableSidebar.json not found, skipping"
fi

echo
echo "Done. Launch Arc to verify your spaces, tabs, and settings are restored."

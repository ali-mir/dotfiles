#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARC_DIR="$DOTFILES_DIR/common/arc"

ARC_SUPPORT="$HOME/Library/Application Support/Arc"
ARC_PLIST_DOMAIN="company.thebrowser.Browser"

mkdir -p "$ARC_DIR"

echo "Exporting Arc browser settings to $ARC_DIR"
echo

# Export preferences
echo "  Exporting preferences..."
defaults export "$ARC_PLIST_DOMAIN" "$ARC_DIR/preferences.plist"
echo "  → $ARC_DIR/preferences.plist"

# Export sidebar (spaces, pinned tabs, folders, links)
if [[ -f "$ARC_SUPPORT/StorableSidebar.json" ]]; then
  echo "  Exporting sidebar (spaces, tabs, links)..."
  cp "$ARC_SUPPORT/StorableSidebar.json" "$ARC_DIR/StorableSidebar.json"
  echo "  → $ARC_DIR/StorableSidebar.json"
else
  echo "  ⚠ StorableSidebar.json not found, skipping"
fi

echo
read -rs -p "  Enter passphrase to encrypt: " PASSPHRASE
echo
if [[ -f "$ARC_DIR/StorableSidebar.json" ]]; then
  printf '%s\n' "$PASSPHRASE" | age -p -o "$ARC_DIR/StorableSidebar.json.age" "$ARC_DIR/StorableSidebar.json"
  rm "$ARC_DIR/StorableSidebar.json"
  echo "  → $ARC_DIR/StorableSidebar.json.age"
fi
if [[ -f "$ARC_DIR/preferences.plist" ]]; then
  printf '%s\n' "$PASSPHRASE" | age -p -o "$ARC_DIR/preferences.plist.age" "$ARC_DIR/preferences.plist"
  rm "$ARC_DIR/preferences.plist"
  echo "  → $ARC_DIR/preferences.plist.age"
fi

echo
echo "Done. Commit the changes to save this snapshot."

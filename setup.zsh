#!/bin/zsh

set -e

REPO_DIR="$HOME/____"
ZSHRC="$REPO_DIR/.zshrc"
ZSHRC_REMOTE="$REPO_DIR/.zshrc_remote"
ZSHRC_LOCAL="$REPO_DIR/.zshrc_local"
HOME_ZSHRC="$HOME/.zshrc"

check_repo_files() {
  if [[ ! -f "$ZSHRC" ]]; then
    echo "Error: $ZSHRC not found. The GitHub repo must contain this file."
    exit 1
  fi
  if [[ ! -f "$ZSHRC_REMOTE" ]]; then
    echo "Error: $ZSHRC_REMOTE not found. The private GitHub repo must contain this file."
    exit 1
  fi
}

ensure_local_config() {
  if [[ ! -f "$ZSHRC_LOCAL" ]]; then
    echo "## .zshrc_local configurations - for this machine only, not synced to GitHub" > "$ZSHRC_LOCAL"
  fi
}

sync_home_zshrc() {
  if [[ -f "$HOME_ZSHRC" ]]; then
    if ! grep -Fxq "source ~/____/.zshrc" "$HOME_ZSHRC"; then
      grep -vxF "source ~/____/.zshrc" "$HOME_ZSHRC" >> "$ZSHRC_LOCAL"
      echo "Backed up extra lines from ~/.zshrc to $ZSHRC_LOCAL"
      echo "source ~/____/.zshrc" > "$HOME_ZSHRC"
      echo "Replaced ~/.zshrc with 'source ~/____/.zshrc'"
    else
      awk '/^source ~\/____\/.zshrc$/ {print; found=1; next} found {print > "'"$ZSHRC_LOCAL"'"} !found {next}' "$HOME_ZSHRC" > "$HOME_ZSHRC.tmp"
      mv "$HOME_ZSHRC.tmp" "$HOME_ZSHRC"
    fi
  else
    echo "source ~/____/.zshrc" > "$HOME_ZSHRC"
    echo "Created ~/.zshrc with 'source ~/____/.zshrc'"
  fi
}

main() {
  check_repo_files
  ensure_local_config
  sync_home_zshrc
  echo "Setup complete."
}

main

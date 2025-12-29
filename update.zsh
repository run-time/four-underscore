#!/bin/zsh

HOME_ZSHRC="$HOME/.zshrc"
CONFIG_DIR="$HOME/____"
ZSHRC_LOCAL="$CONFIG_DIR/.zshrc_local"
LAST_UPDATE_FILE="$CONFIG_DIR/.last_update"
ENV_FILE="$CONFIG_DIR/.env"

load_update_interval() {
  if [[ -f "$ENV_FILE" ]]; then
    export $(grep -E '^GIT_UPDATE_HOURS=' "$ENV_FILE" | xargs)
  fi
  : ${GIT_UPDATE_HOURS:=1}
  UPDATE_INTERVAL=$((GIT_UPDATE_HOURS * 3600))
}

should_update() {
  local now last_update
  now=$(date +%s)
  last_update=$(cat "$LAST_UPDATE_FILE" 2>/dev/null || echo 0)
  (( now - last_update >= UPDATE_INTERVAL )) || [[ "$1" == "--force" ]]
}

update_repo() {
  cd "$CONFIG_DIR" || { echo "Config dir missing. Run setup."; return 1; }
  git fetch origin main --quiet 2>/dev/null
  local_commit=$(git rev-parse HEAD 2>/dev/null)
  remote_commit=$(git rev-parse origin/main 2>/dev/null)
  if [[ "$local_commit" != "$remote_commit" ]]; then
    git pull origin main --quiet && echo "Updated configs."
  fi
}

update_timestamp() {
  date +%s > "$LAST_UPDATE_FILE"
}

source_remote_config() {
  source "$CONFIG_DIR/.zshrc_remote" 2>/dev/null
}

sync_home_zshrc() {
  if [[ -f "$HOME_ZSHRC" ]]; then
    if ! grep -Fxq "source ~/____/.zshrc" "$HOME_ZSHRC"; then
      grep -vxF "source ~/____/.zshrc" "$HOME_ZSHRC" >> "$ZSHRC_LOCAL"
      echo "source ~/____/.zshrc" > "$HOME_ZSHRC"
    else
      awk '/^source ~\/____\/.zshrc$/ {print; found=1; next} found {print > "'"$ZSHRC_LOCAL"'"} !found {next}' "$HOME_ZSHRC" > "$HOME_ZSHRC.tmp"
      mv "$HOME_ZSHRC.tmp" "$HOME_ZSHRC"
    fi
  fi
}

main() {
  load_update_interval
  if should_update "$1"; then
    update_repo
    update_timestamp
  fi
  source_remote_config
  sync_home_zshrc
}

main "$@"

################################################################################
## in order for the following to work you must manually change the contents of
## your ~/.zshrc file to this "source ~/____/.zshrc" (without the quotes)
################################################################################

## run update script to fetch latest configs from GitHub if needed
if [[ -f "$HOME/____/update.zsh" ]]; then
  source "$HOME/____/update.zsh"
fi

## load machine-specific (local) zsh configs
if [[ -f "$HOME/____/.zshrc_local" ]]; then
  source "$HOME/____/.zshrc_local"
fi

## load synced (remote) zsh configs
if [[ -f "$HOME/____/.zshrc_remote" ]]; then
  source "$HOME/____/.zshrc_remote"
fi

################################################################################
#!/usr/bin/env zsh

export PATH="$HOME/.local/bin:$PATH"

setopt null_glob
for file in "${ZDOTDIR:-$HOME/.config/zsh}/conf.d/"*.zsh; do
  [ -r "$file" ] && source "$file"
done

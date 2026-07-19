[[ -r "$ZDOTDIR/user.zsh" ]] && source "$ZDOTDIR/user.zsh"

unset GIT_PAGER
export PAGER=more

HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history hist_ignore_dups

bindkey -e

autoload -Uz compinit
compinit -d "$ZDOTDIR/.zcompdump"

[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
[[ -r "$ZDOTDIR/functions/eza.zsh" ]] && source "$ZDOTDIR/functions/eza.zsh"
[[ -r "$ZDOTDIR/functions/fzf.zsh" ]] && source "$ZDOTDIR/functions/fzf.zsh"

alias c='clear'

typeset -g ZSH_AUTOSUGGEST_STRATEGY=(history)
typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6f737a'
[[ -r "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

PROMPT='%F{#6f737a}%n@%m%f %F{#b6bac0}%~%f %F{#6f737a}%#%f '
RPROMPT=''

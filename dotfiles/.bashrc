# ~/.bashrc: executed by bash(1) for non-login shells.
# See /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for
# examples.

# If not running interactively, don't do anything.
case $- in
*i*) ;;
*) return ;;
esac

source "$HOME/.common.sh"

# Append to the history file, don't overwrite it.
shopt -s histappend

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

HISTSIZE=9999
HISTFILESIZE=9999999

# Check window size after each command and, if necessary, update the values of
# LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will match all
# files and zero or more directories and subdirectories.
#shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Enable programmable completion features.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -f /usr/local/etc/profile.d/bash_completion.sh ]; then
    . /usr/local/etc/profile.d/bash_completion.sh
  fi
fi

type aws_completer >/dev/null 2>&1 && complete -C aws_completer aws

type _awsp &>/dev/null && alias awsp="source _awsp"
[ -f "$HOME/.awsp" ] && export AWS_PROFILE=$(cat "$HOME/.awsp")

alias k="kubectl"
alias ke="k exec -ti"
alias ks="k -n kube-system"
alias kse="k -n kube-system exec -ti"
alias kk="k kustomize"

if [[ -f "$HOME/.complete_alias" ]]; then
  source "$HOME/.complete_alias"
  complete -F _complete_alias k
  complete -F _complete_alias ke
  complete -F _complete_alias ks
  complete -F _complete_alias kse
fi

command -v kubecolor >/dev/null 2>&1 && complete -F __start_kubectl kubecolor

for kc in "$HOME"/.kube/configs/*; do
  if [[ ! -f $kc ]]; then
    continue
  fi
  if [[ -z ${KUBECONFIG:-} ]]; then
    export KUBECONFIG=$kc
  else
    export KUBECONFIG=$KUBECONFIG:$kc
  fi
done

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
[[ -x "$HOME/.local/bin/mise" ]] && eval "$($HOME/.local/bin/mise activate bash)"
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

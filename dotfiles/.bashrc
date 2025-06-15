# ~/.bashrc: executed by bash(1) for non-login shells.
# See /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for
# examples.

# If not running interactively, don't do anything.
case $- in
*i*) ;;
*) return ;;
esac

source $HOME/.common.sh

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

powerline_root=$(pip3 show powerline-status | grep '^Location:' | awk '{print $2}')
if [[ -z "$powerline_root" ]]; then
  powerline_root=$(pip show powerline-status | grep '^Location:' | awk '{print $2}')
fi
if [ -d "$powerline_root" ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  . $powerline_root/powerline/bindings/bash/powerline.sh
fi

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
type /snap/aws-cli/current/usr/bin/python3 >/dev/null 2>&1 && complete -C \
  'SNAP=/snap/aws-cli/current /snap/aws-cli/current/usr/bin/python3 /snap/aws-cli/current/bin/aws_completer' aws

# added by travis gem
[ -f /home/vilmos/.travis/travis.sh ] && source /home/vilmos/.travis/travis.sh

which _awsp >/dev/null 2>&1 && alias awsp="source _awsp"
[ -f $HOME/.awsp ] && export AWS_PROFILE=$(cat $HOME/.awsp)

alias k="kubectl"
alias ke="k exec -ti"
alias ks="k -n kube-system"
alias kse="k -n kube-system exec -ti"
alias kk="k kustomize"

source .complete_alias

complete -F _complete_alias k
complete -F _complete_alias ke
complete -F _complete_alias ks
complete -F _complete_alias kse
complete -F _complete_alias kc

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

eval "$(direnv hook bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

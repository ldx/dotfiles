# ~/.bashrc: executed by bash(1) for non-login shells.
# See /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for
# examples.

# Environment setup — runs for all bash sessions (interactive and non-interactive).
source "$HOME/.common.sh"

# If not running interactively, stop here.
case $- in
*i*) ;;
*) return ;;
esac

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


# Enable programmable completion features.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [[ -n ${HOMEBREW_PREFIX:-} && -f "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
    . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
  elif [ -f /usr/local/etc/profile.d/bash_completion.sh ]; then
    . /usr/local/etc/profile.d/bash_completion.sh
  fi
fi

type aws_completer >/dev/null 2>&1 && complete -C aws_completer aws

type _awsp &>/dev/null && alias awsp="source _awsp"
[ -f "$HOME/.awsp" ] && export AWS_PROFILE=$(cat "$HOME/.awsp")

alias vim="nvim"

alias k="kubectl"
alias ke="k exec -ti"
alias ks="k -n kube-system"
alias kse="k -n kube-system exec -ti"
alias kk="k kustomize"

command -v kubecolor >/dev/null 2>&1 && complete -F __start_kubectl kubecolor

# Create and open a personal Worktrunk worktree.
wtn() {
  if [[ $# -ne 1 ]]; then
    echo "usage: wtn <name>" >&2
    return 2
  fi

  wt switch --create "vilmos/$1"
}

_herdr_pi_workspace() {
  local name=$1
  local cwd=$2
  shift 2

  if ! command -v herdr >/dev/null 2>&1; then
    echo "herdr is not installed" >&2
    return 1
  fi
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is not installed" >&2
    return 1
  fi
  if [[ ! -d $cwd ]]; then
    echo "directory does not exist: $cwd" >&2
    return 1
  fi
  cwd=$(builtin cd -- "$cwd" && pwd -P) || return

  local response pane_id agent_name
  response=$(herdr workspace create --cwd "$cwd" --label "$name" --no-focus) || return
  pane_id=$(jq -r '.result.root_pane.pane_id' <<<"$response")

  if [[ -z $pane_id || $pane_id == null ]]; then
    echo "could not read the new Herdr pane ID" >&2
    return 1
  fi

  agent_name="pi-$(tr '[:upper:]' '[:lower:]' <<<"${pane_id//:/-}")"
  if (( $# )); then
    herdr agent start "$agent_name" --kind pi --pane "$pane_id" -- "$@" || return
  else
    herdr agent start "$agent_name" --kind pi --pane "$pane_id"
  fi
}

# Create a personal Worktrunk worktree and launch Pi in a Herdr workspace.
wtp() {
  if [[ $# -eq 0 ]]; then
    echo "usage: wtp <name> [prompt...]" >&2
    return 2
  fi

  local name=$1
  shift

  if [[ ${HERDR_ENV:-} == 1 ]] || ! command -v herdr >/dev/null 2>&1; then
    wt switch --create --execute pi "vilmos/$name" -- "$@"
    return
  fi

  wt switch --create "vilmos/$name" || return
  _herdr_pi_workspace "$name" "$PWD" "$@"
}

# Create a Herdr workspace and launch Pi in it.
hw() {
  if (( $# < 1 || $# > 2 )); then
    echo "usage: hw <name> [cwd]" >&2
    return 2
  fi

  _herdr_pi_workspace "$1" "${2:-$PWD}"
}

# Launch Pi in a selected or named existing worktree.
wta() {
  wt switch --execute pi "$@"
}

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

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
command -v wt >/dev/null 2>&1 && eval "$(wt config shell init bash)"
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

[ -r "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

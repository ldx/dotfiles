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

  local response workspace_id pane_id agent_name
  response=$(herdr workspace create --cwd "$PWD" --label "$name" --no-focus) || return
  workspace_id=$(jq -r '.result.workspace.workspace_id' <<<"$response")
  pane_id=$(jq -r '.result.root_pane.pane_id' <<<"$response")

  if [[ -z $workspace_id || $workspace_id == null || -z $pane_id || $pane_id == null ]]; then
    echo "wtp: could not read the new Herdr workspace IDs" >&2
    return 1
  fi

  agent_name="pi-$(tr '[:upper:]' '[:lower:]' <<<"${pane_id//:/-}")"
  if (( $# )); then
    herdr agent start "$agent_name" --kind pi --pane "$pane_id" -- "$@" || return
  else
    herdr agent start "$agent_name" --kind pi --pane "$pane_id" || return
  fi

  herdr workspace focus "$workspace_id"
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

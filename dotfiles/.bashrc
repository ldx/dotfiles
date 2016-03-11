# ~/.bashrc: executed by bash(1) for non-login shells.
# See /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for
# examples.

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

source $HOME/.common.sh

# Append to the history file, don't overwrite it.
shopt -s histappend

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

HISTSIZE=10000
HISTFILESIZE=200000

# Check window size after each command and, if necessary, update the values of
# LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will match all
# files and zero or more directories and subdirectories.
#shopt -s globstar

# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below).
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

unset PROMPT_COMMAND
declare -f __git_ps1 > /dev/null && {
    GIT_PS1_SHOWDIRTYSTATE="yes"
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_DESCRIBE_STYLE="branch"
    PROMPT_COMMAND='__git_ps1 "${debian_chroot:+($debian_chroot)}\u@\h:\w${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}" "\\\$ " "[%s]"'
}

if [ -z "$PROMPT_COMMAND" ]; then
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}\$ '
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
    fi
fi

if [ -f ~/.sensible.bash/bash-sensible/sensible.bash ]; then
    . ~/.sensible.bash/bash-sensible/sensible.bash
fi

################################
# G L O B A L  S E T T I N G S #
################################
setopt ALWAYS_LAST_PROMPT ALWAYS_TO_END APPEND_HISTORY AUTO_CD AUTO_LIST \
    AUTO_MENU AUTO_NAME_DIRS AUTO_PARAM_SLASH AUTO_RESUME BANG_HIST \
    NO_CHECK_JOBS NO_HUP CLOBBER CORRECT CORRECT_ALL PRINTEXITVALUE \
    EXTENDED_HISTORY FUNCTION_ARGZERO GLOB HIST_IGNORE_DUPS \
    COMPLETE_IN_WORD HIST_REDUCE_BLANKS MAIL_WARNING POSIX_BUILTINS \
    PRINT_EIGHT_BIT NO_BEEP EXTENDEDGLOB SH_WORD_SPLIT

unsetopt CHASE_DOTS CHASE_LINKS BG_NICE IGNORE_BRACES PROMPT_CR NOMATCH

SAVEHIST=20000
HISTSIZE=20000
HISTFILE=~/.zsh_history
WATCH=notme
WATCHFMT="%n has %a tty%l from %M at %D %T"
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'  # removed /

PAGER="less -r"
LESSCHARSET=utf-8
CVS_RSH=ssh
LC_ALL=hu_HU.UTF-8
EDITOR=vim
VISUAL=vim

case `uname -s` in
    [Dd][Aa][Rr][Ww][Ii][Nn])
        export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
        alias sed="sed -E"
        ;;
    [Ll][Ii][Nn][Uu][Xx])
        alias open=xdg-open
        alias sed="sed -r"
        ;;
esac

if [ "$TERM" = "xterm" ]; then
    TERM=xterm-color
    export TERM
fi

path=( ~/bin /usr/local/bin /usr/local/sbin /sbin /usr/sbin \
    /Library/Frameworks/Python.framework/Versions/Current/bin \
    $JAVA_HOME/bin \
    /usr/local/git/bin \
    /usr/local/git/libexec/git-core \
    /opt/android-sdk-linux/platform-tools/ \
    /opt/android-sdk-linux/tools/ \
    $path )

PATH=~/bin:/Library/Frameworks/Python.framework/Versions/Current/bin:/usr/local/bin:/usr/local/sbin:/sbin:/usr/sbin:$JAVA_HOME/bin:/usr/local/git/bin:/usr/local/git/libexec/git-core:/opt/android-sdk-linux/platform-tools:/opt/android-sdk-linux/tools/:$MAGICK_HOME/bin:/usr/local/mysql/bin:$PATH

ANDROID_SDK_ROOT=/opt/android-sdk-linux

export PAGER LESSCHARSET CVS_RSH LC_ALL PATH EDITOR VISUAL ANDROID_SDK_ROOT

# want core files
#ulimit -c unlimited
ulimit -c 0

#autoload -U promptinit
#promptinit
#prompt adam2 magenta cyan cyan

export MallocBadFreeAbort=1

export WORKON_HOME=~/.virtualenvs
if [ ! -d $WORKON_HOME ]; then
    mkdir $WORKON_HOME
fi

if [ -e /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
fi
if [ -e /etc/bash_completion.d/virtualenvwrapper ]; then
    source /etc/bash_completion.d/virtualenvwrapper
fi

#################
# A L I A S E S #
#################
case `uname -s` in
[Ll][Ii][Nn][Uu][Xx])
    alias ls='ls --color -F'
    ;;
[Ff][Rr][Ee][Ee][Bb][Ss][Dd])
    alias ls='ls -G -F'
    ;;
[Dd][Aa][Rr][Ww][Ii][Nn])
    alias ls='ls -G -F'
    ;;
esac
alias la='ls -al'
alias l='ls -l'
alias screen='TERM=screen screen'
alias scpresume="rsync --partial --progress --rsh=ssh"
alias grep='grep --color'

#####################
# F U N C T I O N S #
#####################
alias calc="noglob _calc" calcfx="noglob _calcfx"

function _calc()
{
    gawk "BEGIN { print $* ; }"
}

function _calcfx () {
    gawk -v CONVFMT="%12.2f" -v OFMT="%.9g"  "BEGIN { print $* ; }"
}

#######################
# C O M P L E T I O N #
#######################
autoload multicomp mtoolsmatch insmodcomp
autoload -U compinit
autoload -Uz vcs_info
compinit

# Tab completion from both ends
setopt completeinword

# Tab completion should be case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Better completion for killall
zstyle ':completion:*:killall:*' command 'ps -u $USER -o cmd'

# What zsh considers a word
#autoload select-word-style
#select-word-style normal

##########################
# K E Y  B I N D I N G S #
##########################
bindkey '^[OA'   history-beginning-search-backward  # Up
bindkey '^[OB'   history-beginning-search-forward  # Down
bindkey '^[^I'   reverse-menu-complete  # ESC TAB
bindkey ' '      magic-space
bindkey '^A'       beginning-of-line
bindkey '^E'     end-of-line
bindkey '^D'     logout
bindkey '^L'     clear-screen
bindkey '^J'     self-insert  # LF
bindkey '^U'     kill-whole-line
bindkey '^W'     vi-backward-kill-word
bindkey '^f'     vi-forward-word
bindkey '^b'     vi-backward-word
bindkey '^/'     undo
bindkey '^x'     kill-word
bindkey '^[[^@'  beginning-of-line
bindkey '^[[e'   end-of-line
# vi style incremental search
bindkey '^R'     history-incremental-search-backward
bindkey '^S'     history-incremental-search-forward
bindkey '^P'     history-beginning-search-backward
bindkey '^N'     history-beginning-search-forward

SEPCHARS='[/ ]'

my-forward-word() {
    if [[ "${BUFFER[CURSOR + 1]}" =~ "${SEPCHARS}" ]]; then
        (( CURSOR += 1 ))
        return
    fi
    while [[ CURSOR -lt "${#BUFFER}" && ! "${BUFFER[CURSOR + 1]}" =~ "${SEPCHARS}" ]]; do
        (( CURSOR += 1 ))
    done
}

zle -N my-forward-word
bindkey '^f' my-forward-word

my-backward-word() {
    if [[ "${BUFFER[CURSOR]}" =~ "${SEPCHARS}" ]]; then
        (( CURSOR -= 1 ))
        return
    fi
    while [[ CURSOR -gt 0 && ! "${BUFFER[CURSOR]}" =~ "${SEPCHARS}" ]]; do
        (( CURSOR -= 1 ))
    done
}

zle -N my-backward-word
bindkey '^b' my-backward-word

my-backward-kill-word() {
    if [[ "${LBUFFER[CURSOR]}" =~ "${SEPCHARS}" ]]; then
        LBUFFER="${LBUFFER[1, CURSOR - 1]}"
        return
    fi
    while [[ CURSOR -gt 0 && ! "${LBUFFER[CURSOR]}" =~ "${SEPCHARS}" ]]; do
            LBUFFER="${LBUFFER[1, CURSOR - 1]}"
    done
}

zle -N my-backward-kill-word
bindkey '^W' my-backward-kill-word

#########################
# T M U X / S C R E E N #
#########################

reattach_tmux() {
    found=0
    my_session="work"
    sessions="`tmux list-session|awk '{print $1$11}'`"
    for s in $sessions; do
        name="`echo $s|cut -d ':' -f 1`"
        attached="`echo $s|cut -d ':' -f 2`"
        if [[ "$name" == "$my_session" ]]; then
            found=1
            if [[ "$attached" != "(attached)" ]]; then
                tmux -2 attach -t $my_session
            fi
        fi
    done
    if [ "$found" -eq "0" ]; then
        tmux -2 new-session -s $my_session
    fi
}

# reattach tmux session
remote_session=0
tmux_installed=0
hash tmux 2>/dev/null && tmux_installed=1
if [ -n "$SSH_CONNECTION" ]; then
    remote_session=1
fi
if [ $remote_session -eq 0 ]; then
    if [ $tmux_installed -ne 0 ]; then
        reattach_tmux
    fi
fi

#############
# O T H E R #
#############

dexify() {
    for f in $*; do
        tmpdir="`mktemp -d`"
        tmpfile="${tmpdir}/classes.dex"
        dx --dex --output=${tmpfile} ${f}
        aapt add ${f} ${tmpfile}
        rm -f ${tmpfile}
        rmdir ${tmpdir}
    done
}

scanify() {
    fuzz_value="50%"
    convert ${1} -fuzz ${3-50%} -trim +repage -modulate 130,130,130 ${2:-$(echo ${1}|awk -F . 'sub(FS $NF,x)')_scan.jpg}
}

###############
# P R O M P T #
###############

setopt prompt_subst
zstyle ':vcs_info:*' actionformats '[%B%b:%F{1}%a%f%%b]'
zstyle ':vcs_info:*' formats '[%F{3}%b%f]'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b:%F{3}%r%f'
zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
autoload -U is-at-least
vcs_info_wrapper() {
    if is-at-least 4.3.7; then
        vcs_info
        if [ -n "$vcs_info_msg_0_" ]; then
            echo "${vcs_info_msg_0_}"
        fi
    fi
}

lsb_release_codename() {
    hash lsb_release 2>/dev/null && lsb_release -c|awk '{print $2}'
}

PROMPT='[%B%n%b@%B%m%b:%B$(lsb_release_codename)%b]%18<..<%~%<<$(vcs_info_wrapper)%# '


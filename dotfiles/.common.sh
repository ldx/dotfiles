# Start tmux automatically.
parent="$(ps -o comm= $PPID)"
if [ -z "$TMUX" -a "$parent" != "sshd" -a "$parent" != "su" -a "$SSH_CONNECTION" = "" ]; then
    which tmux > /dev/null 2>&1 && exec tmux -2
fi

# Environment variables.
export LESSCHARSET=utf-8

export CVS_RSH=ssh

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=hu_HU.UTF-8

export EDITOR=vim
export VISUAL=vim

export LOCAL_PREFIX=$HOME/.local
export CPPFLAGS=-I$LOCAL_PREFIX/include
export LDFLAGS=-L$LOCAL_PREFIX/lib
# export LD_LIBRARY_PATH=$LOCAL_PREFIX/lib:$LD_LIBRARY_PATH

export GPU_MAX_ALLOC_PERCENT=100
export GPU_USE_SYNC_OBJECTS=1

export QUILT_PATCHES=debian/patches

case `uname -s` in
    [Dd][Aa][Rr][Ww][Ii][Nn])
        export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
        export MallocBadFreeAbort=1
        alias sed="sed -E"
        ;;
esac

if [ "$TERM" = "xterm" ]; then
    export TERM=xterm-color
fi

export WORKON_HOME=~/.virtualenvs
if [ ! -d $WORKON_HOME ]; then
    mkdir $WORKON_HOME
fi

if [ -e /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
elif [ -e $LOCAL_PREFIX/bin/virtualenvwrapper.sh ]; then
    source $LOCAL_PREFIX/bin/virtualenvwrapper.sh
elif [ -e /etc/bash_completion.d/virtualenvwrapper ]; then
    source /etc/bash_completion.d/virtualenvwrapper
fi

export GEM_HOME=$HOME/.gem
export BUNDLE_PATH=$GEM_HOME

export GOPATH=$HOME/Projects/go
export GOFLAGS="-mod=readonly"

# prepend_colon(val, var)
prepend_colon() {
    if [ -z "$2" ]; then
        echo $1
    else
        echo $1:$2
    fi
}

# unshift_path(path)
unshift_path() {
    if [ -d $1/sbin ]; then
        export PATH=$(prepend_colon "$1/sbin" $PATH)
    fi
    if [ -d $1/bin ]; then
        export PATH=$(prepend_colon "$1/bin" $PATH)
    fi

    if [ -d $1/share/man ]; then
        export MANPATH=$(prepend_colon "$1/share/man" $MANPATH)
    fi
}

export PATH=""
export MANPATH=""

unshift_path ""
unshift_path "/usr"
unshift_path "/usr/local"
unshift_path "/usr/local/go"
unshift_path "/usr/X11"
unshift_path "/opt"
unshift_path "/opt/local"
unshift_path "$HOME"
unshift_path "$LOCAL_PREFIX"
unshift_path "$GOPATH"
unshift_path "$BUNDLE_PATH"
unshift_path "$HOME/Projects/rumprun/rumprun"
unshift_path "$HOME/.cabal"
unshift_path "$HOME/.local/depot_tools"
if [ -d $HOME/.local/go ]; then
    export GOROOT=$HOME/.local/go
    unshift_path "$GOROOT"
fi

unset _PERLLIBS
if [ -d "$LOCAL_PREFIX/lib/perf" ]; then
    for x in $LOCAL_PREFIX/lib/perl/*; do
        if [ -d "$x" ]; then
            _PERLLIBS=$(prepend_colon "$x" $_PERLLIBS)
        fi
    done
fi
if [ -d "$LOCAL_PREFIX/share/perf" ]; then
    for x in $LOCAL_PREFIX/share/perl/*; do
        if [ -d "$x" ]; then
            _PERLLIBS=$(prepend_colon "$x" $_PERLLIBS)
        fi
    done
fi
export PERL5LIB=$_PERLLIBS

# Create core files.
# ulimit -c unlimited
ulimit -c 0

# Try to bump max number of open fds.
ulimit -n 9999

# Check for files with local environment settings.
for f in .setenv setenv setenv.sh; do
    if [ -f "$HOME/$f" ]; then
        . "$HOME/$f"
    fi
done

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

if [ -d "$LOCAL_PREFIX/share/completions" ]; then
    for f in $LOCAL_PREFIX/share/completions/*; do
        source $f
    done
fi

# Aliases.
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
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Functions.
alias calc="_calc" calcfx="_calcfx"

function _calc()
{
    gawk "BEGIN { print $* ; }"
}

function _calcfx () {
    gawk -v CONVFMT="%12.2f" -v OFMT="%.9g"  "BEGIN { print $* ; }"
}

function stdev() {
    awk '{delta = $1 - avg; avg += delta / NR; mean2 += delta * ($1 - avg); } END { printf "%.2f\n", sqrt(mean2/NR); }'
}

function avg() {
    awk '{sum+=$1} END {printf "%.2f\n", sum/NR}'
}

function add() {
    awk '{sum+=$1} END {printf "%d\n", sum}'
}

function median() {
    gawk \
        'function median(c, v,  d) {
            asort(v, d);
            if (c % 2) {
                return d[(c+1)/2];
            } else {
                return (d[c/2+1]+d[c/2])/2.0;
            }
        }
        {
            count++;
            values[count]=$1;
        }
        END {
            print median(count, values);
        }'
}

function percentile() {
    gawk \
        "function percentile(c, v, p,  d) {
            asort(v, d);
            n=int(c * p - 0.5);
            return d[n];
        }
        BEGIN {
            count=0
        }
        {
            count++;
            values[count]=\$1;
        }
        END {
            print percentile(count, values, 0.95);
        }"
}

function join() {
    IFS=$1
    shift
    echo "$*"
}

ls $HOME/*.retry > /dev/null 2>&1 && mv $HOME/*.retry /tmp/

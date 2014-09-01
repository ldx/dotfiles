parent="$(ps -p $PPID -o comm=)"
if [ "$parent" != "xterm" -a "$parent" != "tmux" ]; then
    return
fi

_s="$(which zsh 2> /dev/null)"
if [ $? -eq 0 ]; then
    exec $_s
fi

arch=$(uname -m)
case $arch in
    i?86)
        if [ -x $HOME/.local/bin/zsh32 ]; then
            ldd $HOME/.local/bin/zsh32 > /dev/null 2>&1 && \
                exec $HOME/.local/bin/zsh32 -l
        fi
        ;;
    x86_64)
        if [ -x $HOME/.local/bin/zsh64 ]; then
            ldd $HOME/.local/bin/zsh64 > /dev/null 2>&1 && \
                exec $HOME/.local/bin/zsh64 -l
        fi
        ;;
    *)
        ;;
esac

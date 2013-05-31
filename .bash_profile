#parent=$(ps -o comm= $PPID)
#if  [ $parent = "sshd" -o $parent = "su" ]; then
arch=$(uname -m)
case $arch in
    i?86)
        if [ -x $HOME/.local/bin/zsh32 ]; then
            exec $HOME/.local/bin/zsh32 -l
        fi
        ;;
    x86_64)
        if [ -x $HOME/.local/bin/zsh64 ]; then
            exec $HOME/.local/bin/zsh64 -l
        fi
        ;;
    *)
        ;;
esac
#fi

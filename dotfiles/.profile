parent=$(ps -o comm= $PPID)
if  [ $parent = "sshd" -o $parent = "su" ]; then
    #arch=$(uname -m)
    #case $arch in
    #    i?86)
    #        if [ -x $HOME/bin/zsh5-static-i386 ]; then
    #    	exec $HOME/bin/zsh5-static-i386 -l
    #        fi
    #        ;;
    #    x86_64)
    #        if [ -x $HOME/bin/zsh5-static-x86_64 ]; then
    #    	exec $HOME/bin/zsh5-static-x86_64 -l
    #        fi
    #        ;;
    #    *)
    #        ;;
    #esac
    if [ -x $HOME/.local/bin/zsh ]; then
	# For now, just use a static 32bit binary.
	exec $HOME/.local/bin/zsh -l
    fi
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r $HOME/.config/dircolors/ls_colors.sh && \
        eval "$(dircolors -b $HOME/.config/dircolors/ls_colors.sh)" || \
        eval "$(dircolors -b)"
fi

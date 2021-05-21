# enable color support of ls
if [[ $(./util/xterm-color-count.bash) == "256" ]] && [[ -x /usr/bin/dircolors ]]; then
    [[ -r $HOME/.config/dircolors/ls_colors.sh ]] && \
        eval "$(dircolors -b $HOME/.config/dircolors/ls_colors.sh)" || \
        eval "$(dircolors -b)"
fi

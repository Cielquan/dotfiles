#!/usr/bin/env bash

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # shellcheck disable=1091
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        # shellcheck disable=1091
        . /etc/bash_completion
    fi
fi

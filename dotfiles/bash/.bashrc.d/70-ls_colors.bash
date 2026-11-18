#!/usr/bin/env bash

# enable color support of ls
# shellcheck disable=1091
. "${HOME}"/.bashrc.d/util/xterm-color-count.bash

if [[ -x /usr/bin/dircolors ]]; then
    if [[ -r "${HOME}"/.config/dircolors/LS_COLORS ]] && [[ "${SUPPORTED_COLORS}" == "256" ]]; then
        eval "$(dircolors -b "${HOME}"/.config/dircolors/LS_COLORS)"
    else
        eval "$(dircolors -b)"
    fi
fi

#!/usr/bin/env bash

# Source: https://raw.githubusercontent.com/l0b0/xterm-color-count/master/xterm-color-count.sh

trap 'tput sgr0' exit       # Clean up even if user hits ^C


# First, test if terminal supports OSC 4 at all.
printf '\e]4;%d;?\a' 0
# shellcheck disable=2162
read -d $'\a' -s -t 0.1 </dev/tty
if [ -z "${REPLY}" ]; then
    # OSC 4 not supported, so we'll fall back to terminfo 
    max=$(tput colors)
else
    # OSC 4 is supported, so use it for a binary search 
    min=0
    max=256
    while [[ $((min+1)) -lt $max ]]; do
        i=$(( (min+max)/2 ))
        printf '\e]4;%d;?\a' $i
        # shellcheck disable=2162
        read -d $'\a' -s -t 0.1 </dev/tty
        if [ -z "${REPLY}" ]; then
            max=${i}
        else
            min=${i}
        fi
    done
fi


SUPPORTED_COLORS=${max}
export SUPPORTED_COLORS
echo "${SUPPORTED_COLORS}"

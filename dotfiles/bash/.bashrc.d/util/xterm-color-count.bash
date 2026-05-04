#!/usr/bin/env bash

# Original source: https://raw.githubusercontent.com/l0b0/xterm-color-count/master/xterm-color-count.sh

trap 'tput sgr0' exit       # Clean up even if user hits ^C

# Function to safely query terminal color support
query_terminal_colors() {
    local min=0
    local max=256

    # First, test if terminal supports OSC 4 at all
    printf '\e]4;%d;?\a' 0

    # Read with longer timeout and proper cleanup
    # shellcheck disable=2162
    if read -d $'\a' -s -t 0.5 REPLY 2>/dev/null; then
        # OSC 4 is supported, use binary search
        while [[ $((min+1)) -lt ${max} ]]; do
            local i=$(( (min+max)/2 ))
            printf '\e]4;%d;?\a' "${i}"

            # shellcheck disable=2162
            if read -d $'\a' -s -t 0.5 REPLY 2>/dev/null && [[ -n "${REPLY}" ]]; then
                min=${i}
            else
                max=${i}
            fi
        done
    else
        # OSC 4 not supported, fall back to terminfo
        max=$(tput colors 2>/dev/null || echo 8)
    fi

    echo "${max}"
}

SUPPORTED_COLORS=$(query_terminal_colors)
export SUPPORTED_COLORS

# Ensure clean output
tput sgr0

# Our ~/.profile should already have made a directory with the supported
# options for us; if not, we won't be wrapping ls(1) with a function at all
[ -d "${HOME}"/.cache/sh/opt/ls ] || return

# If the system has already aliased ls(1) for us, like Slackware or OpenBSD
# does, just get rid of it
unalias ls >/dev/null 2>&1

# Discard GNU ls(1) environment variables if the environment set them
unset -v LS_OPTIONS LS_COLORS

# Define function proper
ls() {

    # POSIX options:
    ## -F to show trailing indicators of the filetype
    ## -q to replace control chars with '?'
    set -- -Fq "$@"
    ## -x to format entries across, not down, if output looks like a terminal
    if [ -t 1 ] ; then
        set -- -x "$@"
    fi

    # GNU options:
    ## Add --block-size=K to always show the filesize in kibibytes
    if [ -e "${HOME}"/.cache/sh/opt/ls/block-size ] ; then
        set -- --block-size=1024 "$@"
    fi
    ## Add --color if the terminal has at least 8 colors
    if [ -e "${HOME}"/.cache/sh/opt/ls/color ] &&
            [ "$(exec 2>/dev/null;tput colors||tput Co||echo 0)" -ge 8 ] ; then
        set -- --color=auto "$@"
    fi
    ## Force the new entry quoting off
    if [ -e "${HOME}"/.cache/sh/opt/ls/quoting-style ] ; then
        set -- --quoting-style=literal "$@"
    fi
    ## Add --time-style='+%Y-%m-%d %H:%M:%S' to show the date in my preferred
    ## (fixed) format
    if [ -e "${HOME}"/.cache/sh/opt/ls/time-style ] ; then
        set -- --time-style='+%Y-%m-%d %H:%M:%S' "$@"
    fi

    # Run ls(1) with the concluded arguments
    command ls "$@"
}

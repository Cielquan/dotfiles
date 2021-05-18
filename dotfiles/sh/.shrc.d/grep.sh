# Our ~/.profile should already have made a directory with the supported
# options for us; if not, we won't be wrapping grep(1) with a function at all
[ -d "$HOME"/.cache/sh/opt/grep ] || return

# Discard GNU grep(1) environment variables if the environment set them
unset -v GREP_OPTIONS

# Define function proper
grep() {

    # Add --binary-files=without-match to gracefully skip binary files
    if [ -e "$HOME"/.cache/sh/opt/grep/binary-files ] ; then
        set -- --binary-files=without-match "$@"
    fi

    # Add --color=auto if the terminal has at least 8 colors
    if [ -e "$HOME"/.cache/sh/opt/grep/color ] &&
        [ "$(exec 2>/dev/null;tput colors||tput Co||echo 0)" -ge 8 ] ; then
        set -- --color=auto "$@"
    fi

    # Add --devices=skip to gracefully skip devices
    if [ -e "$HOME"/.cache/sh/opt/grep/devices ] ; then
        set -- --devices=skip "$@"
    fi

    # Add --directories=skip to gracefully skip directories
    if [ -e "$HOME"/.cache/sh/opt/grep/directories ] ; then
        set -- --directories=skip "$@"
    fi

    # Add --exclude to ignore .gitignore and .gitmodules files
    if [ -e "$HOME"/.cache/sh/opt/grep/exclude ] ; then
        set -- \
            --exclude=.gitignore \
            --exclude=.gitmodules \
            "$@"
    fi

    # Add --exclude-dir to ignore version control dot-directories
    if [ -e "$HOME"/.cache/sh/opt/grep/exclude-dir ] ; then
        set -- \
            --exclude-dir=.cvs \
            --exclude-dir=.git \
            --exclude-dir=.hg \
            --exclude-dir=.svn \
            "$@"
    fi

    # Run grep(1) with the concluded arguments
    command grep "$@"
}

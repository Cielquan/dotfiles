# Run ls -A if we can (-A is not POSIX), ls -a otherwise
la() {
    # Prefer --almost-all (exclude "." and "..") if available
    if [ -e "$HOME"/.cache/sh/opt/ls/almost-all ] ; then
        set -- -A "$@"
    else
        set -- -a "$@"
    fi
    ls "$@"
}

#! /usr/bin/env sh

# Prepend a directory to PATH if it exists and isn't already there
path_prepend() {
    [ -d "$1" ] || return 0
    case ":${PATH}:" in
        *":$1:"*) ;;
        *) PATH="$1${PATH:+:${PATH}}" ;;
    esac
}

# Append a directory to PATH if it exists and isn't already there
path_append() {
    [ -d "$1" ] || return 0
    case ":${PATH}:" in
        *":$1:"*) ;;
        *) PATH="${PATH:+${PATH}:}$1" ;;
    esac
}

path_utils_cleanup() {
    unset -f path_prepend
    unset -f path_append
    unset -f path_utils_cleanup
}

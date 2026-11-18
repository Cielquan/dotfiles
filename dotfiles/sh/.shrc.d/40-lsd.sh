#!/usr/bin/env sh

# grep all directories from ls
lsd() {
    # shellcheck disable=2010
    ls -lF "$@" | grep --color=never '^d'
}

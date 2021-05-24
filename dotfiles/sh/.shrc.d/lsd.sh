#!/usr/bin/env sh

# grep all directories from ls
lsd() {
    ls -lF "$@" | grep --color=never '^d'
}

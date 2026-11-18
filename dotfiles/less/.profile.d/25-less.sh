#!/usr/bin/env sh

# less(1) >= 582 reads lesskey source files directly, no need to compile them with lesskey(1)
if [ -f "${HOME}/.config/less/less" ]; then
    LESSKEYIN=${HOME}/.config/less/less
    export LESSKEYIN
fi

#!/usr/bin/env sh

# If ~/.local/share/pnpm exists, add it to path
if [ -d "${HOME}"/.local/share/pnpm ] ; then
    PNPM_HOME="${HOME}/.local/share/pnpm"
    export PNPM_HOME
    path_prepend "${PNPM_HOME}"
fi

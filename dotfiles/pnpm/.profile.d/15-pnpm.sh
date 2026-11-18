#!/usr/bin/env sh

# If ~/.local/share/pnpm exists, add it to path
if [ -d "${HOME}"/.local/share/pnpm ] ; then
    PNPM_HOME="${HOME}/.local/share/pnpm"
    export PNPM_HOME
    case ":${PATH}:" in
    *":${PNPM_HOME}:"*) ;;
    *) export PATH="${PNPM_HOME}:${PATH}" ;;
    esac
fi

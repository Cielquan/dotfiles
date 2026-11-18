#!/usr/bin/env bash

# Load env vars to customize zoxide, must be loaded before init command
# shellcheck disable=1091
[ -f "${HOME}/.config/zoxide/zoxide_envvars.bash" ] && source "${HOME}/.config/zoxide/zoxide_envvars.bash"

# Load zoxide if installed (needs to be called at the end)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

#!/usr/bin/env bash

FZF_DEFAULT_OPTS_FILE="${HOME}/.config/fzf/fzfrc"
export FZF_DEFAULT_OPTS_FILE

# Set up fzf key bindings and fuzzy completion, if installed
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
fi

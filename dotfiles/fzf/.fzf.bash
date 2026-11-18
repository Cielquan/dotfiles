#!/usr/bin/env bash

FZF_DEFAULT_OPTS_FILE="${HOME}/.config/fzf/fzfrc"
export FZF_DEFAULT_OPTS_FILE

# Add fzf to PATH
if [[ ! "$PATH" == */home/krys/projects_ext/fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}${HOME}.fzf/bin"
fi

# Set up fzf key bindings and fuzzy completion, if installed
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
fi

#!/usr/bin/env bash

# Set path to starship.toml
STARSHIP_CONFIG=${HOME}/.config/starship/starship.toml
export STARSHIP_CONFIG

# Load starship prompt if installed (needs to be called at the end)
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

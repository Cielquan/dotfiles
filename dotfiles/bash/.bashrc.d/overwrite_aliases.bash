#!/usr/bin/env bash

### Relabeled / Overwritten commands

if command -v colordiff &> /dev/null; then
    alias diff='colordiff'
fi

# rg -> ripgrep
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

if command -v prek &> /dev/null; then
    alias pre-commit='prek'
fi

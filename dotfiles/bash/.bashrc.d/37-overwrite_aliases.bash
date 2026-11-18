#!/usr/bin/env bash

### Relabeled / Overwritten commands

if command -v colordiff &> /dev/null; then
    alias diff='colordiff'
fi

if command -v prek &> /dev/null; then
    alias pre-commit='prek'
fi

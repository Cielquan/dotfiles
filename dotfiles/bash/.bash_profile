#!/usr/bin/env bash

# Bash login shells skip ~/.profile when this file exists, so source it here
# shellcheck disable=SC1090
if [ -f ~/.profile ]; then . ~/.profile; fi

# shellcheck disable=SC1090
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

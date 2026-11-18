#!/usr/bin/env bash

# Make the "sudo" prompt more useful, without requiring access to "visudo".
SUDO_PROMPT='[sudo] password for %u on %h: '
export SUDO_PROMPT

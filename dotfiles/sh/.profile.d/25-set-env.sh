#!/usr/bin/env sh

# If ~/.shrc exists, set ENV to that
if [ -f "${HOME}"/.shrc ] ; then
    ENV=${HOME}/.shrc
    export ENV
fi

#!/usr/bin/env sh

CONF_DIR=${HOME}/.config/less/
LESSKEY=${CONF_DIR}/lesskey

if ! [ -f "${LESSKEY}" ] || \
    [ -n "$(find -L "${CONF_DIR}/less" -prune -newer "${LESSKEY}")" ]; then
        lesskey -o "${LESSKEY}" "${CONF_DIR}/less"
fi

if [ -f "${LESSKEY}" ]; then
    export LESSKEY
fi

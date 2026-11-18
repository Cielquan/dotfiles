#!/usr/bin/env bash

# Open bash shell in docker container
dockerbash () {
    docker exec -it "${1}" bash
}
export -f dockerbash


# Allow global pip to install globally
gpip() {
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}
export -f gpip


whatsgoingon() {
    for i in $(find . -maxdepth 1 -type d | sed -e 's/\.\///' -e '/\./d'); do
        pushd "${i}" >/dev/null || ( echo "pushd failed." && return 1 )
        echo "$(tput bold)${i}$(tput sgr0)"
        if [ -z "$(git status --porcelain)" ]; then
            echo "is clean"
        else
            git status -s
        fi
        popd >/dev/null || ( echo "popd failed." && return 1 )
    done
}
export -f whatsgoingon


# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && ( cd "$_" || ( echo "cd failed." && return 1 ));
}
export -f mkd


# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null &> /dev/null; then
		local arg=-sbh
	else
		local arg=-sh
	fi
	if [[ -n "$*" ]]; then
		du $arg -- "$@"
	else
		du $arg .[^.]* ./*
	fi;
}
export -f fs


# Create a data URL from a file
function dataurl() {
	mimeType=$(file -b --mime-type "${1}")
	local mimeType
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8"
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "${1}" | tr -d '\n')"
}
export -f dataurl


# Shortcut to show current shell version
ver() {
    printf '%s\n' "${BASH_VERSION:-unknown}"
}

#!/usr/bin/env sh

BOLD="$(tput bold 2>/dev/null || printf '')"
UNDERLINE="$(tput smul 2>/dev/null || printf '')"
BLINK="$(tput blink 2>/dev/null || printf '')"
REVERSE="$(tput rev 2>/dev/null || printf '')"

BLACK="$(tput setaf 0 2>/dev/null || printf '')"
RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
BLUE="$(tput setaf 4 2>/dev/null || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"  # often violet
CYAN="$(tput setaf 6 2>/dev/null || printf '')"
WHITE="$(tput setaf 7 2>/dev/null || printf '')"

BLACK_BG="$(tput setab 0 2>/dev/null || printf '')"
RED_BG="$(tput setab 1 2>/dev/null || printf '')"
GREEN_BG="$(tput setab 2 2>/dev/null || printf '')"
YELLOW_BG="$(tput setab 3 2>/dev/null || printf '')"
BLUE_BG="$(tput setab 4 2>/dev/null || printf '')"
MAGENTA_BG="$(tput setab 5 2>/dev/null || printf '')"  # often violet
CYAN_BG="$(tput setab 6 2>/dev/null || printf '')"
WHITE_BG="$(tput setab 7 2>/dev/null || printf '')"

NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

info() {
    printf '%b\n' "${BOLD}${CYAN}>${NO_COLOR} $*"
}

warn() {
    printf '%b\n' "${YELLOW}[!] $*${NO_COLOR}"
}

error() {
    printf '%b\n' "${RED}[x] $*${NO_COLOR}" >&2
}

success() {
    printf '%b\n' "${GREEN}[✓]${NO_COLOR} $*"
}

installed() {
    command -v "$1" 1> /dev/null 2>&1
}

answer_is_yes() {
    printf '%b' "${YELLOW}[?] $1 (y/n) ${NO_COLOR}"
    read -r REPLY </dev/tty
    printf "\n"
    answers="yY"
    test "${answers#*$REPLY}" != "$answers" && return 0 || return 1
}

test_writeable() {
    # Test if a location is writeable by trying to write to it. Windows does not let
    # you test writeability other than by writing: https://stackoverflow.com/q/1999988
    # source: https://sh.rustup.rs
    local path
    path="${1:-}/test.txt"
    if touch "${path}" 2>/dev/null; then
        rm "${path}"
        return 0
    else
        return 1
    fi
}

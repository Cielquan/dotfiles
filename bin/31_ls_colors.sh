#!/usr/bin/env sh

# No questions asked

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   START
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing LS_COLORS ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install LS_COLORS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

dircolors_dir=$HOME/.config/dircolors
info "Download LS_COLORS."
link="https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/LS_COLORS"
curl "${CURL_ARGS}" --create-dirs -o "$dircolors_dir/LS_COLORS" "${link}"
success "Done."
info "Install LS_COLORS."
dircolors -b "$dircolors_dir/LS_COLORS" > "$dircolors_dir/ls_colors.sh"
success "Done."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing LS_COLORS finished ..."

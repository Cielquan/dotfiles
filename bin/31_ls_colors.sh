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

install_ls_colors() {
    dircolors_dir=${HOME}/.config/dircolors
    info "Download LS_COLORS."
    link="https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/LS_COLORS"
    # shellcheck disable=2086
    curl ${CURL_ARGS} --create-dirs -o "${dircolors_dir}/LS_COLORS" "${link}"
    success "Done."
}
install_ls_colors

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing LS_COLORS finished ..."

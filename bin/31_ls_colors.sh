#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)
. ${SCRIPT_DIR}/util/shell_script_utils.sh

info "Installing LS_COLORS ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install LS_COLORS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Download and install LS_COLORS"
dircolors_dir=$HOME/.config/dircolors

local link="https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/LS_COLORS"
curl ${curl_args} --create-dirs -o $dircolors_dir/LS_COLORS ${link}
dircolors -b $dircolors_dir/LS_COLORS > $dircolors_dir/ls_colors.sh
success "Done."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing LS_COLORS finished ..."

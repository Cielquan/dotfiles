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

mkdir -p $dircolors_dir
wget -qO $dircolors_dir/LS_COLORS https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/LS_COLORS
dircolors -b $dircolors_dir/LS_COLORS > $dircolors_dir/ls_colors.sh

success "LS_COLORS installed ..."

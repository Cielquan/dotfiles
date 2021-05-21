#!/usr/bin/env sh

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   install LS_COLORS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n\n ## Download and install LS_COLORS\n"
dircolors_dir=$HOME/.config/dircolors

mkdir -p $dircolors_dir
wget -qO $dircolors_dir/LS_COLORS https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/LS_COLORS
dircolors -b $dircolors_dir/LS_COLORS > $dircolors_dir/ls_colors.sh

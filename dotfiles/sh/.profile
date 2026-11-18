#!/usr/bin/env sh

# shellcheck disable=1091
. "${HOME}/.profile.d/util/path_utils.sh"

path_prepend /usr/sbin
path_prepend "${HOME}/.local/bin"
path_prepend "${HOME}/bin"

# Load all supplementary scripts in ~/.profile.d
for sh in "${HOME}"/.profile.d/*.sh ; do
    [ -e "${sh}" ] || continue
    # shellcheck disable=1090
    . "${sh}"
done
unset -v sh

# If ~/.shinit exists, set ENV to that
if [ -f "${HOME}"/.shinit ] ; then
    ENV=${HOME}/.shinit
    export ENV
fi

path_utils_cleanup

#!/usr/bin/env sh

# Add ~/.local/bin to PATH if it exists
if [ -d "${HOME}"/.local/bin ] ; then
    PATH=${HOME}/.local/bin:${PATH}
fi

# Add ~/bin to PATH if it exists
if [ -d "${HOME}/bin" ] ; then
    PATH="${HOME}/bin:${PATH}"
fi

# Add /usr/sbin to PATH if it exists
if [ -d /usr/sbin ] ; then
    PATH="/usr/sbin:${PATH}"
fi

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

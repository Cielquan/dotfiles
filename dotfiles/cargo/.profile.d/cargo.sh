# If ~/.cargo/env exists, set ENV to that
if [ -f "${HOME}"/.cargo/env ] ; then
    # shellcheck disable=1091
    . "${HOME}/.cargo/env"
fi

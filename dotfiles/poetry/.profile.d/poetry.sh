# If ~/.poetry/env exists, set ENV to that
if [ -f "${HOME}"/.poetry/env ] ; then
    # shellcheck disable=1091
    . "${HOME}/.poetry/env"
fi

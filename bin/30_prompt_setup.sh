#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Parse argv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# PARSER
while [ "$#" -gt 0 ]; do
    case "$1" in

    -f | -y | --force | --yes)
        FORCE="yes"
        shift 1
        ;;

    -- | -n | --no)
        shift 1
        ;;

    *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   START
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

info "Installing starship prompt ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install starship prompt
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if installed starship; then
    info "starship prompt is already installed."
else
    info "Installing starship prompt."
    link="https://starship.rs/install.sh"
    # shellcheck disable=2086
    curl ${CURL_ARGS} ${link} | sh -s -- -y
    success "Done."
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Installing starship prompt finished ..."

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
    -s | --backup-suffix)
        BACKUP_SUFFIX="$2"
        shift 2
        ;;

    -s=* | --backup-suffix=*)
        BACKUP_SUFFIX="${1#*=}"
        shift 1
        ;;

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

info "Installing dotfiles ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install dotfiles
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_dotfiles() {
    echo hi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

success "Installing dotfiles finished ..."

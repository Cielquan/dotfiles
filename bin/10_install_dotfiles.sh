#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Util
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DOTFILES_DIR="${SCRIPT_DIR}/../dotfiles"

TMP_DIR="${SCRIPT_DIR}/tmp"
if ! [ -d "${TMP_DIR}" ]; then
    mkdir "${TMP_DIR}" 2> /dev/null
fi

tmp_cleanup() {
    rm -rf "${SCRIPT_DIR}/tmp"
}
trap tmp_cleanup EXIT

FILE_LIST="${TMP_DIR}/FILE_LIST"
touch "${FILE_LIST}"

create_dotfiles_list() {
    PACKAGES="${1},"
    find "${DOTFILES_DIR}" -type f | sed "s|${DOTFILES_DIR}/||g" | while read -r FILE; do
        if [ "${PACKAGES#*${FILE%%/*},}" != "${PACKAGES}" ]; then
            printf "%s," "${FILE}" >> "${FILE_LIST}"
        fi
    done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Parse argv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# DEFAULTS
BACKUP_SUFFIX=".df.bak"

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
    echo "create list"
    create_dotfiles_list "curl"
    echo "loop list"

    tr ',' '\n' < "${FILE_LIST}" | while read -r FILE; do
        source_file="${DOTFILES_DIR}/${FILE}"
        target_file="${HOME}/${FILE#*/}"
        backup_file="${target_file}${BACKUP_SUFFIX}"

        if [ -f "${target_file}" ]; then
            mv "${target_file}" "${backup_file}"
        fi

        # https://stackoverflow.com/questions/8488253/how-to-force-cp-to-overwrite-without-confirmation
        mkdir -p "$(dirname -- "${target_file}")"
        yes | \cp -f "${source_file}" "${target_file}"
    done
}
install_dotfiles

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

tmp_cleanup
success "Installing dotfiles finished ..."

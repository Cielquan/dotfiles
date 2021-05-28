#!/usr/bin/env sh

set -e

SCRIPT_DIR=$( cd -P -- "$(dirname -- "$(command -v -- "${0}")")" && pwd -P)
# shellcheck disable=1091
. "${SCRIPT_DIR}/util/shell_script_utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Util
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DOTFILES_DIR="${SCRIPT_DIR}/../dotfiles"

# TMP DIR
TMP_DIR="${SCRIPT_DIR}/tmp"
if ! [ -d "${TMP_DIR}" ]; then
    mkdir "${TMP_DIR}" 2> /dev/null
fi

tmp_cleanup() {
    rm -rf "${SCRIPT_DIR}/tmp"
}
trap tmp_cleanup EXIT

# INSTALL LIST
DIR_LIST="${TMP_DIR}/DIR_LIST"
touch "${DIR_LIST}"

create_dotfiles_dir_list() {
    INSTALLS="${1}" # Comma separated list (string)
    echo "${INSTALLS}" | tr ',' '\n' | while read -r GROUP; do
        echo "${GROUP}"
        case "${GROUP}" in
            "bash")
                echo "sh" >> "${DIR_LIST}"
                echo "bash" >> "${DIR_LIST}"
                ;;
            "bin" | "cargo" | "curl" | "git" | "gpg" | "less" | "pdb" | "pdbpp" | "pip" | "poetry" | "sh" | "wget")
                echo "${GROUP}" >> "${DIR_LIST}"
                ;;
            "starship" | "prompt")
                echo "sh" >> "${DIR_LIST}"
                echo "bash" >> "${DIR_LIST}"
                echo "starship" >> "${DIR_LIST}"
                ;;
            "default")
                echo "sh" >> "${DIR_LIST}"
                echo "bash" >> "${DIR_LIST}"
                echo "bin" >> "${DIR_LIST}"
                echo "curl" >> "${DIR_LIST}"
                echo "less" >> "${DIR_LIST}"
                echo "wget" >> "${DIR_LIST}"
                ;;
            "coding")
                echo "cargo" >> "${DIR_LIST}"
                echo "git" >> "${DIR_LIST}"
                echo "gpg" >> "${DIR_LIST}"
                echo "pdb" >> "${DIR_LIST}"
                echo "pdbpp" >> "${DIR_LIST}"
                echo "pip" >> "${DIR_LIST}"
                echo "poetry" >> "${DIR_LIST}"
                ;;
            "all")
                echo "all" > "${DIR_LIST}"
                break
                ;;
        esac
    done

    sorted_list=$(sort "${DIR_LIST}" | uniq -u | tr '\n' ',' | sed 's/,$//')
    echo "${sorted_list}" > "${DIR_LIST}"
}

# FILE LIST
FILE_LIST="${TMP_DIR}/FILE_LIST"
touch "${FILE_LIST}"

create_dotfiles_file_list() {
    # Add ',' in front and back so that every entry is surrounded by ','. Makes sure that
    # substrings of one another are no false positives below e.g. 'sh' and 'bash'
    DIRS=",${1}," # Comma separated list (string)
    find "${DOTFILES_DIR}" -type f | sed "s|${DOTFILES_DIR}/||g" | while read -r FILE; do
        # If all or the root dir of the 'FILE' is in 'DIRS' list
        if [ "${DIRS}" = ",all," ] || [ "${DIRS#*,${FILE%%/*},}" != "${DIRS}" ]; then
            printf "%s," "${FILE}" >> "${FILE_LIST}"
        fi
    done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Parse argv
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# DEFAULTS
INSTALL="y"
INSTALL_LIST="default"
BACKUP_SUFFIX=".df.bak"
BACKUP="y"

# PARSER
while [ "$#" -gt 0 ]; do
    case "$1" in
    --uninstall)
        INSTALL="n"
        shift 1
        ;;

    --install-list)
        INSTALL_LIST="$2"
        shift 2
        ;;

    --install-list=*)
        INSTALL_LIST="${1#*=}"
        shift 1
        ;;

    -s | --backup-suffix)
        BACKUP_SUFFIX="$2"
        shift 2
        ;;

    -s=* | --backup-suffix=*)
        BACKUP_SUFFIX="${1#*=}"
        shift 1
        ;;

    --no-backup)
        BACKUP="n"
        shift 1
        ;;

    -f | -y | --force | --yes)
        FORCE="y"
        shift 1
        ;;

    -)
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

info "(Un)Installing dotfiles ..."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install dotfiles
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_dotfiles() {
    Q="Do you want to install dotfiles for ${INSTALL_LIST}?"
    DEFAULT_ANSWER="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
        info "Create list of files to copy."
        create_dotfiles_dir_list "${INSTALL_LIST}"
        create_dotfiles_file_list "$(cat "${DIR_LIST}")"
        success "Done."

        info "Copying files."
        tr ',' '\n' < "${FILE_LIST}" | while read -r FILE; do
            source_file="${DOTFILES_DIR}/${FILE}"
            target_file="${HOME}/${FILE#*/}"
            backup_file="${target_file}${BACKUP_SUFFIX}"

            if [ "${BACKUP}" = "y" ] && [ -f "${target_file}" ]; then
                info "Backup '${target_file}' to '${backup_file}'."
                mv -f "${target_file}" "${backup_file}"
                success "Done."
            fi

            info "Copy '${FILE}' to' '${target_file}'."
            # https://stackoverflow.com/questions/8488253/how-to-force-cp-to-overwrite-without-confirmation
            mkdir -p "$(dirname -- "${target_file}")"
            # shellcheck disable=SC2216
            yes | \cp -f "${source_file}" "${target_file}"
            success "Done."
        done
    fi
}

git_user_data() {
    GIT_USER_FILE="${HOME}/.gitconfig.d/user.gitconfig"

    question "Please enter your name used for git: "
    read -r git_name < /dev/tty
    question "Please enter your email used for git: "
    read -r git_email < /dev/tty
    question "Please enter your signingKey used for git: "
    read -r git_signingKey < /dev/tty

cat << EOF > "${GIT_USER_FILE}"
# WARNING !!!
# This file was created by the dotfiles script.
# Changes are overwritten when rerunning the script.
# The file is deleted when running the script to uninstall dotfiles.

[user]
    name=${git_name}
    email=${git_email}
EOF

    if [ -n "${git_signingKey}" ]; then
        echo "    signingKey=${git_signingKey}" >> "${GIT_USER_FILE}"
    fi
}

git_warning() {
    warn "WARNING The gitconfig uses 'bright' colors added in git version 2.26.0." \
        "Please make sure that your git version is greater or equal elsewise you will" \
        "experience errors when running 'git'."
}

git_setup() {
    DIRS=",$(cat "${DIR_LIST}"),"
    if [ "${DIRS}" = ",all," ] || [ "${DIRS#*,git,}" != "${DIRS}" ]; then
        git_user_data
        git_warning
    fi
}

if [ "${INSTALL}" = "y" ]; then
    install_dotfiles
    git_setup
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   Install dotfiles
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uninstall_dotfiles() {
    Q="Do you want to uninstall dotfiles for ${INSTALL_LIST}?"
    DEFAULT_ANSWER="yes"
    if answer_is_yes "${Q}" "${FORCE}" "${DEFAULT_ANSWER}"; then
        info "Create list of files to delete."
        create_dotfiles_dir_list "${INSTALL_LIST}"
        create_dotfiles_file_list "$(cat "${DIR_LIST}")"
        success "Done."

        info "Deleting files."
        tr ',' '\n' < "${FILE_LIST}" | while read -r FILE; do
            target_file="${HOME}/${FILE#*/}"
            backup_file="${target_file}${BACKUP_SUFFIX}"

            info "Removing file '${target_file}'."
            rm -f "${target_file}"
            success "Done."

            if [ "${BACKUP}" = "y" ] && [ -f "${backup_file}" ]; then
                info "Restoring backup from file '${backup_file}'."
                mv -f "${backup_file}" "${target_file}"
                success "Done."
            fi
        done
    fi
}

if [ "${INSTALL}" = "n" ]; then
    uninstall_dotfiles
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#   FINISH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

tmp_cleanup
success "(Un)Installing dotfiles finished ..."

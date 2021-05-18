# Function to manage contents of PATH variable within the current shell
path() {

    # Check first argument to figure out operation
    case $1 in

        # List current directories in PATH
        list|'')
            set -- "$PATH":
            while [ -n "$1" ] ; do
                case $1 in
                    :*) ;;
                    *) printf '%s\n' "${1%%:*}" ;;
                esac
                set -- "${1#*:}"
            done
            ;;

        # Helper function checks directory argument makes sense
        _argcheck)
            shift
            if [ "$#" -gt 2 ] ; then
                printf >&2 'path(): %s: too many arguments\n' "$1"
                return 2
            fi
            case $2 in
                *:*)
                    printf >&2 'path(): %s: %s contains colon\n' "$@"
                    return 2
                    ;;
            esac
            return 0
            ;;

        # Add a directory at the start of $PATH
        insert)
            if ! [ "$#" -eq 2 ] ; then
                set -- "$1" "$PWD"
            fi
            path _argcheck "$@" || return
            if path check "$2" ; then
                printf >&2 'path(): %s: %s already in PATH\n' "$@"
                return 1
            fi
            PATH=${2}${PATH:+:"$PATH"}
            ;;

        # Add a directory to the end of $PATH
        append)
            if ! [ "$#" -eq 2 ] ; then
                set -- "$1" "$PWD"
            fi
            path _argcheck "$@" || return
            if path check "$2" ; then
                printf >&2 'path(): %s: %s already in PATH\n' "$@"
                return 1
            fi
            PATH=${PATH:+"$PATH":}${2}
            ;;

        # Remove a directory from $PATH
        remove)
            if ! [ "$#" -eq 2 ] ; then
                set -- "$1" "$PWD"
            fi
            path _argcheck "$@" || return
            if ! path check "$2" ; then
                printf >&2 'path(): %s: %s not in PATH\n' "$@"
                return 1
            fi
            PATH=$(
                path=:$PATH:
                path=${path%%:"$2":*}:${path#*:"$2":}
                path=${path#:}
                printf '%s:' "$path"
            )
            PATH=${PATH%%:}
            ;;

        # Remove the first directory in $PATH
        shift)
            case $PATH in
                '')
                    printf >&2 'path(): %s: PATH is empty!\n' "$@"
                    return 1
                    ;;
                *:*)
                    PATH=${PATH#*:}
                    ;;
                *)
                    # shellcheck disable=SC2123
                    PATH=
                    ;;
            esac
            ;;

        # Remove the last directory in $PATH
        pop)
            case $PATH in
                '')
                    printf >&2 'path(): %s: PATH is empty!\n' "$@"
                    return 1
                    ;;
                *:*)
                    PATH=${PATH%:*}
                    ;;
                *)
                    # shellcheck disable=SC2123
                    PATH=
                    ;;
            esac
            ;;

        # Check whether a directory is in PATH
        check)
            path _argcheck "$@" || return
            if ! [ "$#" -eq 2 ] ; then
                set -- "$1" "$PWD"
            fi
            case :$PATH: in
                *:"$2":*) return 0 ;;
            esac
            return 1
            ;;

        # Print help output (also done if command not found)
        help)
            cat <<'EOF'
path(): Manage contents of PATH variable

USAGE:
  path [list]
    Print the current directories in PATH, one per line (default command)
  path insert [DIR]
    Add directory DIR (default $PWD) to the front of PATH
  path append [DIR]
    Add directory DIR (default $PWD) to the end of PATH
  path remove [DIR]
    Remove directory DIR (default $PWD) from PATH
  path shift
    Remove the first directory from PATH
  path pop
    Remove the last directory from PATH
  path check [DIR]
    Return whether directory DIR (default $PWD) is a component of PATH
  path help
    Print this help message
EOF
            ;;

        # Command not found
        *)
            printf >&2 'path(): %s: Unknown command (try "help")\n' "$1"
            return 2
            ;;
    esac
}

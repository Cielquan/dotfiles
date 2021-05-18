# Create a directory and change into it
mkcd() {
    mkdir -p -- "$1" || return
    # shellcheck disable=SC2164
    cd -- "$1"
}

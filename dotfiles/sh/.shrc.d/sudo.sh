# Add the -H parameter to sudo(8) calls, always use the target user's $HOME
sudo() {
    case $1 in
        -v) ;;
        *) set -- -H "$@" ;;
    esac
    command sudo "$@"
}

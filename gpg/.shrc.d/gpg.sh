# Update GPG_TTY for clean use of pinentry(1) etc
GPG_TTY=$(command -p tty) || return
export GPG_TTY

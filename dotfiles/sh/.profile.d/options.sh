#!/usr/bin/env sh

# Cache the options available to certain programs.  Run all this in a subshell
# (none of its state needs to endure in the session)
(
options() {

    # Check or create the directory to cache the options
    # Shift the program name off; remaining arguments are the options to check
    dir=${HOME}/.cache/sh/opt/${1}
    prog=${1}
    shift

    # Directory already exists; bail out
    [ -d "${dir}" ] && return

    # Create the directory and step into it
    mkdir -p -- "${dir}" || return
    cd -- "${dir}" || return

    # Write the program's --help output to a file, even if it's empty
    # This probably only works with GNU tools in general
    "${prog}" --help </dev/null >help 2>/dev/null || return

    # Iterate through remaining arguments (desired options), creating files to
    # show they're available if found in the help output
    for opt do
        command grep -q -- \
            '[^[:alnum:]]--'"${opt}"'[^[:alnum:]]' help || continue
        touch -- "${opt}"
    done
}

# Cache options for grep(1)
options grep \
    binary-files \
    color \
    devices \
    directories \
    exclude \
    exclude-dir

# Cache options for ls(1)
options ls \
    almost-all \
    block-size \
    color \
    human-readable \
    quoting-style \
    time-style
)

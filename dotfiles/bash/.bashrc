# Make sure the shell is interactive
case $- in
    *i*) ;;
    *) return ;;
esac

# Don't do anything if restricted, not even sourcing the ENV file; testing
# whether $- contains 'r' doesn't work, because Bash doesn't set that flag
# until after .bashrc has evaluated
! shopt -q restricted_shell 2>/dev/null || return

# Clear away all aliases; we do this here rather than in the $ENV file shared
# between POSIX shells, because ksh relies on aliases to implement certain
# POSIX utilities, like fc(1) and type(1)
unalias -a

# If ENV is set, source it to get all the POSIX-compatible interactive stuff;
# we should be able to do this even if we're running a truly ancient Bash
if [ -n "${ENV}" ] ; then
    # shellcheck disable=1090
    . "${ENV}"
fi

# Ensure we're using at least version 3.0
# shellcheck disable=SC2128
[ -n "${BASH_VERSINFO}" ] || return    # Check version array exists (>=2.0)
((BASH_VERSINFO[0] >= 3)) || return  # Check actual major version number

# Clear away command_not_found_handle if a system bashrc file set it up
# unset -f command_not_found_handle

# Keep around 32K lines of history in file
HISTFILESIZE=32768

# Ignore duplicate commands
HISTCONTROL=ignoredups

# Keep the times of the commands in history
HISTTIMEFORMAT='%F %T  '

# Use a more compact format for the `time` builtin's output
TIMEFORMAT='real:%lR user:%lU sys:%lS'

# Correct small errors in directory names given to the `cd` builtin
shopt -s cdspell
# Check that hashed commands still exist before running them
shopt -s checkhash
# Update LINES and COLUMNS after each command if necessary
shopt -s checkwinsize
# Put multi-line commands into one history entry
shopt -s cmdhist
# Include filenames with leading dots in pattern matching
shopt -s dotglob
# Enable extended globbing: !(foo), ?(bar|baz)...
shopt -s extglob
# Append history to $HISTFILE rather than overwriting it
shopt -s histappend
# If history expansion fails, reload the command to try again
shopt -s histreedit
# Load history expansion result as the next command, don't run them directly
shopt -s histverify
# Don't assume a word with a @ in it is a hostname
shopt -u hostcomplete
# Don't change newlines to semicolons in history
shopt -s lithist
# Don't try to tell me when my mail is read
shopt -u mailwarn
# Don't complete a Tab press on an empty line with every possible command
shopt -s no_empty_cmd_completion
# Use programmable completion, if available
shopt -s progcomp
# Warn me if I try to shift nonexistent values off an array
shopt -s shift_verbose
# Don't search $PATH to find files for the `source` builtin
shopt -u sourcepath

# These options only exist since Bash 4.0-alpha
if ((BASH_VERSINFO[0] >= 4)) ; then

    # Correct small errors in directory names during completion
    shopt -s dirspell
    # Allow double-star globs to match files and recursive paths
    shopt -s globstar

    # Warn me about stopped jobs when exiting
    # Available since 4.0, but only set it if >=4.1 due to bug:
    # <https://lists.gnu.org/archive/html/bug-bash/2009-02/msg00176.html>
    if ((BASH_VERSINFO[1] >= 1)) ; then
        shopt -s checkjobs
    fi

    # Expand variables in directory completion
    # Only available since 4.3
    if ((BASH_VERSINFO[1] >= 3)) ; then
        shopt -s direxpand
    fi
fi

# Load Bash-specific startup files
for bash in "${HOME}"/.bashrc.d/*.bash ; do
    [[ -e ${bash} ]] || continue
    # shellcheck disable=1090
    source "${bash}"
done
unset -v bash

# Load starship prompt if installed (needs to be called at the end)
if command -v starship &> /dev/null; then
    eval "$(starship init "${0}")"
fi

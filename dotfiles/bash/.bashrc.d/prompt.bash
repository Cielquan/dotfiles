# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Show current git branch in prompt.
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}


source util/color_check.bash

# https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html
if [ "$color_prompt" = yes ]; then
# std: PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1='\[\033[0m\]\A `
        `\[\033[0m\]${debian_chroot:+($debian_chroot)}`
        `\[\033[1;92m\]\u@\h`
        `\[\033[0m\]:`
        `\[\033[1;96m\]\w `
        `\[\033[0;93m\]$(parse_git_branch)`
        `\[\033[1;91m\]\n\$ \[\033[0m\]'
else
# std: PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    PS1='\A ${debian_chroot:+($debian_chroot)}\u@\h:\w $(parse_git_branch)\$'
fi

unset color_prompt


# On error prints error code before next prompt
PROMPT_COMMAND='ec=$?; test $ec = 0 || echo "*** Exit Code: $ec ***" >&2'
# PROMPT_COMMAND equivalent for bash-preexec framework
precmd_exit_code() { ec=$?; test $ec = 0 || echo "*** Exit Code: $ec ***" >&2; }
precmd_functions+=(precmd_exit_code)

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

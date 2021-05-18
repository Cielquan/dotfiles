# Some systems' /etc/profile setups export their prompt strings (PS1, PS2...),
# which really fouls things up when switching between non-login shells; let's
# put things right by unsetting each of them to break the export, and then just
# setting them as simple variables
unset PS1
PS1='$ '
unset PS2
PS2='> '
unset PS3
PS3='? '
unset PS4
PS4='+ '

# If we have an SSH_CLIENT or SSH_CONNECTION environment variable, put the
# hostname in PS1 too.
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_CONNECTION" ] ; then
    PS1=$(hostname -s)'$ '
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ] && [ -r ~/.dircolors ]; then
    eval "$(dircolors -b ~/.dircolors)"
else
    eval "$(dircolors -b)"
fi

#!/usr/bin/env bash

# Enable simple aliases to be sudo'ed. ("sudone"?)
# http://www.gnu.org/software/bash/manual/bashref.html#Aliases says: "If the
# last character of the alias value is a space or tab character, then the next
# command word following the alias is also checked for alias expansion."
alias sudo='sudo '


# Add safty nets
alias chgrp='chgrp --preserve-root' # fail to operate recursively on '/'
alias chmod='chmod --preserve-root' # fail to operate recursively on '/'
alias chown='chown --preserve-root' # fail to operate recursively on '/'
alias cp="cp -iv"
#             │└─ list copied files
#             └─ prompt before overwriting an existing file
alias ln='ln -i' # adding confirmation
alias mv="mv -iv"
#             │└─ list moved files
#             └─ prompt before overwriting an existing file
alias rm='rm -I --preserve-root' # prompt if deleting more than 3 files at a time && do not delete '/'#


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# https://askubuntu.com/questions/423646/use-of-default-alias-alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


### Adding default options
alias mkdir='mkdir -p' # Make parent dirs if needed
alias mountt='mount | column -t' # Make mount command output pretty and human readable format
alias remount='sudo mount -a'
alias ping='ping -c 5' # Standard ping to only do 5


### New commands
alias fastping='ping -c 25 -s.2' # Fast ping -> 5 pings/sec for 5 secs
alias loc='git ls-files | xargs wc -l' # line in files in git repo (only tracked)
alias now='date +"%T"' # current time hh:mm:ss
alias nowdate='date +"%d-%m-%Y"' # current date dd-MM-yyyy
alias week='date +%V' # Get week number
alias path='echo -e ${PATH//:/\\n}' # Show PATH variable
alias reload="exec \${SHELL} -l" # Reload the shell (i.e. invoke as a login shell)

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"
# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"


if command -v netstat &> /dev/null; then
    alias ports='netstat -tulanp' # Show open ports
fi
# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

alias rmd='rm -rf -I --preserve-root'
#alias wakeupnas01='/usr/bin/wakeonlan 00:11:32:11:15:FC' ## replace mac with your actual server mac address #

alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias dupgrade='sudo apt dist-upgrade'


# Activate python default venvs
alias vac='source .venv/bin/activate'
alias vacw='source .venv/Scripts/activate'


### Shortcuts
alias c='clear' # Shortcut for clear
alias g='git'
alias sha1='openssl sha1' # Shortcut for openssl sha1


### Relabeled / Overwritten commands
if command -v colordiff &> /dev/null; then
    alias diff='colordiff'
fi


### cd aliases
alias cd..='cd ..' ## get rid of command not found
alias ..='cd ..' # cd 1 dir up
alias .2='cd ../../' # cd 2 dir up
alias ...='cd ../../' # cd 2 dir up
alias .3='cd ../../../' # cd 3 dir up
alias ....='cd ../../../' # cd 3 dir up
alias .4='cd ../../../../' # cd 4 dir up
alias .....='cd ../../../../' # cd 4 dir up
alias .5='cd ../../../../../' # cd 5 dir up
alias ......='cd ../../../../../' # cd 5 dir up


#### Get os name via uname ###
#_myos="$(uname)"
#
#### add alias as per os using $_myos ###
#case $_myos in
#   Linux) alias foo='/path/to/linux/bin/foo';;
#   FreeBSD|OpenBSD) alias foo='/path/to/bsd/bin/foo' ;;
#   SunOS) alias foo='/path/to/sunos/bin/foo' ;;
#   *) ;;
#esac


### Docker
alias dockerka='docker rm -f $(docker ps -aq)' # Remove all docker container
alias dockerkilltotal='docker rm -f $(docker ps -aq); docker network prune -f' # Remove all docker container and networks
alias dockerimageclean='docker rmi -f $(docker images -aq)' # Remove all images
alias dcup='docker-compose up -d'

dockerbash () {
    docker exec -it "${1}" bash
}
export -f dockerbash


alias steam-wine='wine ~/.wine/drive_c/Program\ Files\ \(x86\)/Steam/Steam.exe'


### python / pip
gpip() {
    PIP_REQUIRE_VIRTUALENV="" pip "$@"
}
export -f gpip

alias pipup='python -m pip install -U pip'
alias pydebug='pip install -U pdbpp ipython devtools[pygments] py-devtools-builtin'


whatsgoingon() {
    for i in $(find . -maxdepth 1 -type d | sed -e 's/\.\///' -e '/\./d'); do
        pushd "${i}" >/dev/null || ( echo "pushd failed." && return 1 )
        echo "$(tput bold)${i}$(tput sgr0)"
        if [ -z "$(git status --porcelain)" ]; then
            echo "is clean"
        else
            git status -s
        fi
        popd >/dev/null || ( echo "popd failed." && return 1 )
    done
}
export -f whatsgoingon


# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && ( cd "$_" || ( echo "cd failed." && return 1 ));
}
export -f mkd


# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null &> /dev/null; then
		local arg=-sbh
	else
		local arg=-sh
	fi
	if [[ -n "$*" ]]; then
		du $arg -- "$@"
	else
		du $arg .[^.]* ./*
	fi;
}
export -f fs


# Create a data URL from a file
function dataurl() {
	mimeType=$(file -b --mime-type "${1}")
	local mimeType
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8"
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "${1}" | tr -d '\n')"
}
export -f dataurl

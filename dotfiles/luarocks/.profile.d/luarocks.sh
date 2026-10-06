#!/usr/bin/env sh

# Add ~/.luarocks/bin to PATH if it exists
if [ -d "${HOME}"/.luarocks/bin ] ; then
    PATH=${HOME}/.luarocks/bin:${PATH}
fi

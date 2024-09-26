#!/bin/bash

if type "xclip" > /dev/null 2>&1; then 
    echo "skipped : xclip has already installed"
else
    echo "installing xclip"
    if type "brew" > /dev/null 2>&1; then 
        echo "mac has pbcopy command instead, skipped"
    elif type "apt-get" > /dev/null 2>&1; then 
        if [[ `id -u` -ne 0 ]]; then
            sudo apt-get install -y xclip
        else
            apt-get install -y xclip
        fi
    else
        echo "no supported package manager found"
        exit
    fi
fi

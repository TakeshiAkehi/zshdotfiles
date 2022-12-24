#!/bin/bash

if type "vim" > /dev/null 2>&1; then 
    echo "skipped : vim has already installed"
else
    echo "installing vim"
    if type "brew" > /dev/null 2>&1; then 
        brew install vim
    elif type "apt-get" > /dev/null 2>&1; then 
        if [[ `id -u` -ne 0 ]]; then
            sudo apt-get install -y vim
        else
            apt-get install -y vim
        fi
    else
        echo "no supported package manager found"
        exit
    fi
fi

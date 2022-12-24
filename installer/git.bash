#!/bin/bash

if type "git" > /dev/null 2>&1; then 
    echo "skipped : git has already installed"
else
    echo "installing git"
    if type "brew" > /dev/null 2>&1; then 
        brew install git
    elif type "apt-get" > /dev/null 2>&1; then 
        if [[ `id -u` -ne 0 ]]; then
            sudo apt-get install -y git
        else
            apt-get install -y git
        fi
    else
        echo "no supported package manager found"
        exit
    fi
fi

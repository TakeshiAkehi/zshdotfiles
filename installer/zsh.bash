#!/bin/bash

if type "zsh" > /dev/null 2>&1; then 
    echo "skipped : zsh has already installed"
else
    echo "installing zsh"
    if type "apt-get" > /dev/null 2>&1; then 
        if [[ `id -u` -ne 0 ]]; then
            sudo apt-get install -y zsh 
        else
            apt-get install -y zsh 
        fi
    else
        echo "no supported package manager found"
        exit
    fi
    touch ${HOME}/.zshrc
fi

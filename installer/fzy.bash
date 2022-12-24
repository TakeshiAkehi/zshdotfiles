#!/bin/bash

if type "fzy" > /dev/null 2>&1; then 
    echo "skipped : fzy has already installed"
else
    echo "installing fzy"
    if type "brew" > /dev/null 2>&1; then 
        brew install fzy
    elif type "apt-get" > /dev/null 2>&1; then 
        if [[ `id -u` -ne 0 ]]; then
            sudo apt-get install -y fzy
        else
            apt-get install -y fzy
        fi
    else
        echo "no supported package manager found"
        exit
    fi
fi

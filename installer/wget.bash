#!/bin/bash

if type "wget" > /dev/null 2>&1; then 
    echo "skipped : wget has already installed"
else
    echo "installing wget"
    if type "brew" > /dev/null 2>&1; then 
        brew install wget
    elif type "apt-get" > /dev/null 2>&1; then 
        if [[ `id -u` -ne 0 ]]; then
            sudo apt-get install -y wget
        else
            apt-get install -y wget
        fi
    else
        echo "no supported package manager found"
        exit
    fi
fi

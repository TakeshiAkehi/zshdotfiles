#!/bin/bash

if type "curl" > /dev/null 2>&1; then 
    echo "skipped : curl has already installed"
else
    echo "installing curl"
    if type "brew" > /dev/null 2>&1; then 
        brew install curl
    elif type "apt-get" > /dev/null 2>&1; then 
        if [[ `id -u` -ne 0 ]]; then
            sudo apt-get install -y curl
        else
            apt-get install -y curl
        fi
    else
        echo "no supported package manager found"
        exit
    fi
fi

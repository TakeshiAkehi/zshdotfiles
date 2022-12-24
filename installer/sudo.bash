#!/bin/bash

if type "sudo" > /dev/null 2>&1; then 
    echo "skipped : sudo has already installed"
else
    echo "installing sudo"
    if type "apt-get" > /dev/null 2>&1; then 
        if [[ `id -u` -ne 0 ]]; then
            echo "no permission to install sudo"
            exit
        else
            apt-get install -y sudo
        fi
    else
        echo "no supported package manager found"
        exit
    fi
fi

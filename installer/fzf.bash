#!/bin/bash

if type "fzf" > /dev/null 2>&1; then 
    echo "skipped : fzf has already installed"
else
    echo "installing fzf"
    if type "brew" > /dev/null 2>&1; then 
        brew install fzf
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi

    if [[ "${SHELL}" == *bash* ]]; then
        source ~/.bashrc
    elif [[ "${SHELL}" == *zsh* ]]; then
        source ~/.zshrc
    else
        echo "unknown shell, skipped cmd : source ~/.*rc"
    fi
fi

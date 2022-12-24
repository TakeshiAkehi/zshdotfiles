#!/bin/bash

if type "zinit" > /dev/null 2>&1; then 
    echo "skipped : zinit has already installed"
else
    echo "installing zinit"
    bash -c "export NO_INPUT=1; export NO_ANNEXES=1; $(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    zsh -c "source ~/.zshrc; zinit self-update"
fi




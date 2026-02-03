#!/bin/bash

# Install cargo (rustup)
if type "cargo" > /dev/null 2>&1; then
    echo "skipped : cargo has already installed"
else
    echo "installing cargo (rustup)"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Install lazygit
if type "lazygit" > /dev/null 2>&1; then
    echo "skipped : lazygit has already installed"
else
    echo "installing lazygit"
    if type "brew" > /dev/null 2>&1; then
        brew install lazygit
    else
        go install github.com/jesseduffield/lazygit@latest
    fi
fi

# Install zellij
if type "zellij" > /dev/null 2>&1; then
    echo "skipped : zellij has already installed"
else
    echo "installing zellij"
    if type "brew" > /dev/null 2>&1; then
        brew install zellij
    else
        cargo install zellij
    fi
fi

# Install delta
if type "delta" > /dev/null 2>&1; then
    echo "skipped : delta has already installed"
else
    echo "installing delta"
    if type "brew" > /dev/null 2>&1; then
        brew install git-delta
    else
        cargo install git-delta
    fi
fi

# Install zoxide
if type "zoxide" > /dev/null 2>&1; then
    echo "skipped : zoxide has already installed"
else
    echo "installing zoxide"
    if type "brew" > /dev/null 2>&1; then
        brew install zoxide
    else
        cargo install zoxide --locked
    fi
fi

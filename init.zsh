#!/bin/zsh

CDIR=$(cd $(dirname $0);pwd)

touch ~/.zshrc
apt update
apt install -y git curl wget fzf fzy

apt install -y gcc g++ make cmake
wget "https://dystroy.org/broot/download/x86_64-linux/broot"
mv broot /usr/local/bin
chmod +x /usr/local/bin/broot
broot
source ~/.zshrc

bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
source ~/.zshrc
zinit self-update
source ~/.zshrc

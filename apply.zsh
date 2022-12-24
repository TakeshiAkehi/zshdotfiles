#!/bin/zsh
CDIR=$(cd $(dirname $0);pwd)

ln -s -f ${CDIR}/dotfiles/.vimrc ${HOME}/.vimrc

mkdir -p ~/dotrc

ln -s -f ${CDIR}/configs/.zinit_conf ${HOME}/dotrc/.zinit_conf
echo "source ${HOME}/dotrc/.zinit_conf" >> ~/.zshrc

ln -s -f ${CDIR}/configs/.zsh_conf ${HOME}/dotrc/.zsh_conf
echo "source ${HOME}/dotrc/.zsh_conf" >> ~/.zshrc

ln -s -f ${CDIR}/configs/.fzf_widgets_conf ${HOME}/dotrc/.fzf_widgets_conf
echo "source ${HOME}/dotrc/.fzf_widgets_conf" >> ~/.zshrc

source ~/.zshrc
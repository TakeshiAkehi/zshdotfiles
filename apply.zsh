#!/bin/zsh
CDIR=$(cd $(dirname $0);pwd)

ln -s -f ${CDIR}/dotfiles/.p10k.zsh ${HOME}/.p10k.zsh 
ln -s -f ${CDIR}/dotfiles/.vimrc ${HOME}/.vimrc
ln -s -f ${CDIR}/dotfiles/verbs.hjson ${HOME}/.config/broot/verbs.hjson

mkdir ~/dotrc -p

ln -s -f ${CDIR}/configs/.zinit_conf ${HOME}/dotrc/.zinit_conf
echo "source ${HOME}/dotrc/.zinit_conf" >> ~/.zshrc

ln -s -f ${CDIR}/configs/.zsh_conf ${HOME}/dotrc/.zsh_conf
echo "source ${HOME}/dotrc/.zsh_conf" >> ~/.zshrc

ln -s -f ${CDIR}/configs/.p10k_conf ${HOME}/dotrc/.p10k_conf
echo "source ${HOME}/dotrc/.p10k_conf" >> ~/.zshrc

ln -s -f ${CDIR}/configs/.fzf_widgets_conf ${HOME}/dotrc/.fzf_widgets_conf
echo "source ${HOME}/dotrc/.fzf_widgets_conf" >> ~/.zshrc

source ~/.zshrc
source ~/.zshrc
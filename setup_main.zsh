CDIR=$(cd $(dirname $0);pwd)
cd ${CDIR}

bash zsh_install.sh
zsh init.zsh
zsh apply.zsh
zsh
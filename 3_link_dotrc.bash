# dotrc.zshがシェル起動時にsourceされるように.zshrcに追記
CDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
LINKCMD="source ${CDIR}/dotrc.zsh"
WDIR=${CDIR}/addon

rm -f "${WDIR}/zsh-compnetions-init.executed"

if grep "${LINKCMD}" "${HOME}"/.zshrc >/dev/null; then
    echo "dotrc already enabled"
else
    echo "enabled dotrc"
    echo "" >> ${HOME}/.zshrc
    echo "### added by zshdotfiles" >> ${HOME}/.zshrc
    echo "${LINKCMD}" >> ${HOME}/.zshrc
    echo "### end of zshdotfiles chunk" >> ${HOME}/.zshrc
    echo "" >> ${HOME}/.zshrc
    echo "added to .zshrc : ${LINKCMD}"
fi
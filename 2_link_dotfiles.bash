CDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
WDIR=${CDIR}/dotfiles
BDIR=${CDIR}/bkup

DOT_FILES=(.vimrc)
for file in ${DOT_FILES[@]}
do
    if [ -e ${HOME}/${file} ]; then
        echo "${file} already exists"
        bkupfile=${BDIR}/${file}.`date "+%Y%m%d_%H%M%S"`
        echo " - backup : ${bkupfile}"
        mv ${HOME}/${file} ${bkupfile}
    fi
    echo "created link : ${WDIR}/$file -> $HOME/$file"
    ln -s ${WDIR}/$file $HOME/$file
done


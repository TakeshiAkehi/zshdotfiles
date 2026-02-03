CDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
WDIR=${CDIR}/dotfiles
BDIR=${CDIR}/bkup

# dotfiles配下の全ファイルのシンボリックリンクを$HOMEに作成
cd "${WDIR}"
find . -type f | while read -r file; do
    # 先頭の "./" を除去
    file="${file#./}"

    target_dir=$(dirname "${HOME}/${file}")

    # 親ディレクトリが存在しない場合は作成
    if [ ! -d "${target_dir}" ]; then
        echo "creating directory : ${target_dir}"
        mkdir -p "${target_dir}"
    fi

    if [ -e "${HOME}/${file}" ]; then
        echo "${file} already exists"
        # バックアップディレクトリ構造を作成
        bkup_dir=$(dirname "${BDIR}/${file}")
        mkdir -p "${bkup_dir}"
        bkupfile="${BDIR}/${file}.$(date "+%Y%m%d_%H%M%S")"
        echo " - backup : ${bkupfile}"
        mv "${HOME}/${file}" "${bkupfile}"
    fi
    echo "created link : ${WDIR}/${file} -> ${HOME}/${file}"
    ln -s "${WDIR}/${file}" "${HOME}/${file}"
done
cd "${CDIR}"


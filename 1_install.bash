CDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
WDIR=${CDIR}/installer

### 必要ソフトインストール
# bash ${WDIR}/sudo.bash
# bash ${WDIR}/zsh.bash
# bash ${WDIR}/wget.bash
# bash ${WDIR}/curl.bash
# bash ${WDIR}/git.bash
# bash ${WDIR}/fzf.bash
# bash ${WDIR}/fzy.bash
# bash ${WDIR}/vim.bash
bash ${WDIR}/zinit.bash

sudo chsh -s $(which zsh)


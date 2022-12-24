# addonフォルダ内に記述した設定をsourceする
CDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
WDIR=${CDIR}/addon

source ${WDIR}/.zsh_conf
source ${WDIR}/.zinit_conf
source ${WDIR}/.fzf_widgets_conf
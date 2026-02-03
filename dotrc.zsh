# addonフォルダ内に記述した設定をsourceする
## シェルログイン時に毎回呼び出される想定
CDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
WDIR=${CDIR}/addon

source ${WDIR}/zsh_conf.zsh
source ${WDIR}/zinit_conf.zsh
source ${WDIR}/tui.zsh
# source ${WDIR}/gnu_commands.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
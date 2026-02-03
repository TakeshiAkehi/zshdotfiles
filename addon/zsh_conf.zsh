# shellの操作モードをvimモードに
set -o vi

# widgetのおまじない？
autoload -Uz compinit
compinit -u

# コマンド履歴設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
export HISTSIZE=1000
export SAVEHIST=10000
setopt share_history           # 履歴を他のシェルとリアルタイム共有する
setopt hist_ignore_all_dups    # 同じコマンドをhistoryに残さない
setopt hist_ignore_space       # historyに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks      # historyに保存するときに余分なスペースを削除する
setopt hist_save_no_dups       # 重複するコマンドが保存されるとき、古い方を削除する
setopt inc_append_history      # 実行時に履歴をファイルにに追加していく

# お手軽エイリアス
## .zshrc
alias zshrc="vim ${HOME}/.zshrc; source ${HOME}/.zshrc"
## remove ansi escapes (色付き文字の出力から文字だけフィルタ)
### 例: cat test.txt | noansi 
alias noansi="sed -e $'s/\x1b\[[0-9;]*m//g'"


alias pbcopy='xclip -selection clipboard'

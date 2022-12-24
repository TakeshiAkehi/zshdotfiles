CDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

# gitなどのサブコマンド補完
zinit ice wait lucid
zinit light zsh-users/zsh-completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit
    compinit
fi
if [ ! -e ${CDIR}/zsh-compnetions-init.executed ]; then
    # 初回設定
    rm -f ~/.zcompdump; compinit
    touch "${CDIR}/zsh-compnetions-init.executed "
fi

# 直近のコマンド履歴から薄文字で候補表示
zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

# インストール済のコマンドが緑で表示される
zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

# 覚えてない．見た目がきれいになりそう
zinit ice wait lucid
zinit light chrissicool/zsh-256color

# "cd" で直近のディレクトリ履歴をfzyで選択
# "cd .." 親ディレクトリをfzyで選択
zinit ice wait lucid
zinit light b4b4r07/enhancd

# イケてる見た目にする
# "p10k configure" で設定
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Ctrl+r でコマンド履歴をfzfで選択
# 他にも色んなウィジェットついてるが使わない
zinit ice wait lucid
zinit light ytet5uy4/fzf-widgets
bindkey '^r' fzf-insert-history
zle -N fzf-insert-history

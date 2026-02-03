xdg-mime default vim.desktop text/plain
export EDITOR=vim
export VISUAL=vim

alias lgit='lazygit'

s() {
		export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    command spf "$@"
    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}

eval "$(zoxide init zsh --no-aliases)"
cd() {
    __zoxide_z "$@"
}

sz() {
    local dir
    dir=$(zoxide query -i)
    if [ -n "$dir" ]; then
        __zoxide_z "$dir"
    fi
}
z() {
    # EXITEDセッションを除外してアクティブなセッションのみ取得（ANSIカラーコード除去）
    local sessions
    sessions=$(zellij list-sessions 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | grep -v EXITED | grep -v '^\s*$')

    if [ -z "$sessions" ]; then
        zellij
    else
        local selected
        selected=$(echo "[New Session]\n$sessions" | fzf --prompt="Zellij Session> " --header="Select session or create new")

        if [ -n "$selected" ]; then
            if [ "$selected" = "[New Session]" ]; then
                zellij
            else
                local session_name
                session_name=$(echo "$selected" | awk '{print $1}')
                zellij attach "$session_name"
            fi
        fi
    fi

    # EXITEDセッションを全て削除
    zellij delete-all-sessions -y 2>/dev/null
}

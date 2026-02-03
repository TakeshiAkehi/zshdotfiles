xdg-mime default vim.desktop text/plain
export EDITOR=vim
export VISUAL=vim

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

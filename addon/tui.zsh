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

# zoxideコマンドが存在するか確認
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
    
    # zoxideが正常にロードされた場合のみ、cdをzoxideに差し替える
    if (( $+functions[__zoxide_z] )); then
			cd() {
					# __zoxide_z 関数が存在するかチェック
					if (( $+functions[__zoxide_z] )); then
							__zoxide_z "$@"
					else
							# 存在しない場合は、ビルトインのcdを呼び出す
							echo "WARN : falled back to builtin-cd"
							builtin cd "$@"
					fi
			}
    fi
else
    # zoxideがない場合は何もしない（通常のcdがそのまま使われる）
    # 必要に応じてログを出したい場合はここに記述
    # echo "zoxide not found, using default cd"
fi

x() {
    local dir
    dir=$(zoxide query -i)
    if [ -n "$dir" ]; then
        builtin cd "$dir"
    fi
}

function y() {
	if [ -n "$YAZI_LEVEL" ]; then
        echo "Error: Already inside a Yazi subshell (Level: $YAZI_LEVEL)"
        echo "Exit this shell to return to the parent Yazi instance."
        return 1
    fi
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && cd -- "$cwd"
	rm -f -- "$tmp"
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

# Git Worktree Manager
gwt() {
    local subcmd="${1:-help}"
    shift 2>/dev/null

    case "$subcmd" in
        add)    _gwt_add "$@" ;;
        list)   _gwt_list ;;
        cd)     _gwt_cd ;;
        remove) _gwt_remove ;;
        *)      _gwt_help ;;
    esac
}

_gwt_help() {
    cat <<'EOF'
Usage: gwt <subcommand>

Subcommands:
  add [branch]    Create worktree with specified branch (vared input if omitted)
  add --issue     Select GitHub issue via fzf, auto-generate branch name
  list            List existing worktrees
  cd              Select worktree via fzf and cd into it
  remove          Select worktree via fzf and remove it
EOF
}

# worktree作成 + submodule初期化の共通処理
_gwt_init_worktree() {
    local branch_name="$1" wt_dir="$2" base_branch="$3"

    # 既にディレクトリが存在する場合の処理
    if [ -d "$wt_dir" ]; then
        echo "Worktree directory already exists at ${wt_dir}."
        builtin cd "$wt_dir" || return 1
        echo "Ensuring submodules are initialized..."
        git submodule update --recursive --init
        git submodule foreach --recursive 'git lfs pull'
        return 0
    fi

    # ブランチ作成とworktree追加
    if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        echo "Using existing local branch: ${branch_name}"
        git worktree add "$wt_dir" "$branch_name" || return 1
    elif git show-ref --verify --quiet "refs/remotes/origin/${branch_name}"; then
        echo "Tracking existing remote branch: ${branch_name}"
        git worktree add "$wt_dir" "$branch_name" || return 1
    else
        echo "Creating new branch '${branch_name}' from '${base_branch}'"
        git worktree add -b "$branch_name" "$wt_dir" "$base_branch" || return 1
    fi

    builtin cd "$wt_dir" || return 1
    echo "Initializing submodules..."
    git submodule update --recursive --init
    git submodule foreach --recursive 'git lfs pull'
    echo "Done. Now on branch '${branch_name}' at ${wt_dir}"
}

_gwt_add() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
    local wt_base="${GWT_BASE_DIR:-$(dirname "$repo_root")}"
    local branch_name="$1"
    local base_branch="HEAD" # デフォルトの派生元

    # 引数がない場合、または --issue の場合に名前を決定
    if [[ "$1" == "--issue" ]]; then
        if ! command -v gh &>/dev/null; then echo "gh CLI not found"; return 1; fi
        local issue=$(gh issue list --state open --limit 50 --json number,title --template '{{range .}}#{{.number}} {{.title}}{{"\n"}}{{end}}' | fzf --prompt="Issue> ")
        [ -z "$issue" ] && return 0
        local issue_num=$(echo "$issue" | sed 's/^#\([0-9]*\) .*/\1/')
        local issue_title=$(echo "$issue" | sed 's/^#[0-9]* //')
        branch_name="feature/${issue_num}-$(echo "$issue_title" | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]/-/g; s/[^a-z0-9-]//g' | cut -c1-50)"
        vared -p "Edit branch name> " branch_name
    elif [ -z "$branch_name" ]; then
        vared -p "Branch name> " branch_name
    fi

    [ -z "$branch_name" ] && return 0

    # ブランチの存在チェックと派生元選択
		local local_exists=$(git show-ref "refs/heads/${branch_name}" >/dev/null 2>&1 && echo "yes")
		local remote_exists=$(git show-ref "refs/remotes/origin/${branch_name}" >/dev/null 2>&1 && echo "yes")

    if [[ -n "$local_exists" || -n "$remote_exists" ]]; then
        echo "Branch '${branch_name}' already exists (Local: ${local_exists:-no}, Remote: ${remote_exists:-no})."
        echo "Choose action:"
        local action=$(echo "Use existing branch\nPick a different base and create new (force rename)\nCancel" | fzf --prompt="Action> ")
        
        if [[ "$action" =~ "Pick" ]]; then
            base_branch=$(git branch -a | sed 's/..//' | fzf --prompt="Select base branch> ")
            [ -z "$base_branch" ] && return 0
        elif [[ "$action" == "Cancel" ]]; then
            return 0
        fi
    else
        # 新規ブランチの場合の確認
        echo -n "Branch '${branch_name}' does not exist. Create it? [y/N] "
        read -k 1 res; echo
        [[ "$res" != "y" ]] && return 0
        base_branch=$(git branch -a | sed 's/..//' | fzf --prompt="Select base branch (default: HEAD)> ")
        [ -z "$base_branch" ] && base_branch="HEAD"
    fi

    local wt_dirname="${branch_name//\//-}"
    local wt_dir="${wt_base}/${wt_dirname}"
    _gwt_init_worktree "$branch_name" "$wt_dir" "$base_branch"
}

_gwt_list() {
    git rev-parse --show-toplevel &>/dev/null || {
        echo "Error: Not inside a git repository." >&2
        return 1
    }
    git worktree list
}

_gwt_cd() {
    git rev-parse --show-toplevel &>/dev/null || {
        echo "Error: Not inside a git repository." >&2
        return 1
    }

    local selected
    selected=$(git worktree list | fzf --prompt="Worktree> " --header="Select worktree to cd into")

    if [ -z "$selected" ]; then
        echo "Cancelled."
        return 0
    fi

    local wt_path
    wt_path=$(echo "$selected" | awk '{print $1}')
    cd "$wt_path"
}

_gwt_remove() {
    # 常にメインリポジトリのパスを取得して、そこから操作を行う
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
    
    # メインworktreeは削除させない
    #local selected=$(git worktree list | grep -v "\[.*\]" | awk -v main="$repo_root" '$1 != main' | fzf --prompt="Remove Worktree> ")
		local selected=$(git worktree list | awk -v main="$repo_root" '$1 != main' | fzf --prompt="Remove Worktree> ")
    [ -z "$selected" ] && return 0

    local wt_path=$(echo "$selected" | awk '{print $1}')

    echo "Remove worktree at ${wt_path}? [y/N/f] (f=force)"
    read -k 1 confirm; echo
    
    # 重要: git worktree remove はメインリポジトリのディレクトリから実行するのが確実
    case "$confirm" in
        [yY])
            (cd "$repo_root" && git worktree remove "$wt_path")
            ;;
        [fF])
            echo "Force removing..."
            (cd "$repo_root" && git worktree remove -f "$wt_path")
            ;;
        *)
            echo "Cancelled."
            ;;
    esac
}

cdp() {
    local clip_path=$(xclip -selection clipboard -o | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [ -z "$clip_path" ]; then
        echo "Clipboard is empty."
        return 1
    fi
    if [ -f "$clip_path" ]; then
        local target_dir=$(dirname "$clip_path")
        builtin cd "$target_dir"
    elif [ -d "$clip_path" ]; then
        builtin cd "$clip_path"
    else
        echo "Clipboard is not a valid file or directory"
        return 1
    fi
}


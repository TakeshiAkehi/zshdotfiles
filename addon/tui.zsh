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

sz() {
    local dir
    dir=$(zoxide query -i)
    if [ -n "$dir" ]; then
        builtin cd "$dir"
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
    local branch_name="$1" wt_dir="$2"

    # ブランチが既に存在するか確認
    if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
        echo "Branch '${branch_name}' already exists."
        if [ -d "$wt_dir" ]; then
            echo "Worktree already exists at ${wt_dir}, changing directory."
            cd "$wt_dir" || return 1
            echo "Ensuring submodules are initialized..."
            git submodule update --recursive --init
            git submodule foreach --recursive 'git lfs pull'
            return 0
        fi
        git worktree add "$wt_dir" "$branch_name" || return 1
    else
        git worktree add -b "$branch_name" "$wt_dir" || return 1
    fi

    cd "$wt_dir" || return 1
    echo "Worktree created at ${wt_dir}"

    echo "Initializing submodules..."
    git submodule update --recursive --init
    echo "Pulling LFS objects for submodules..."
    git submodule foreach --recursive 'git lfs pull'

    echo "Done. Now on branch '${branch_name}' at ${wt_dir}"
}

_gwt_add() {
    # gitリポジトリ確認
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        echo "Error: Not inside a git repository." >&2
        return 1
    }

    local wt_base="${GWT_BASE_DIR:-$(dirname "$repo_root")}"

    if [[ "$1" == "--issue" ]]; then
        # --issue モード: GitHub issueから自動生成
        if ! command -v gh &>/dev/null; then
            echo "Error: gh CLI is not installed." >&2
            return 1
        fi

        local issue
        issue=$(gh issue list --state open --limit 50 --json number,title \
            --template '{{range .}}#{{.number}} {{.title}}{{"\n"}}{{end}}' \
            | fzf --prompt="Issue> " \
                  --header="Select issue | ctrl-w: open web | ctrl-/: toggle preview" \
                  --preview 'gh issue view {1}' \
                  --preview-window 'up:50%:wrap' \
                  --bind 'ctrl-w:execute-silent(gh issue view {1} --web)' \
                  --bind 'ctrl-/:toggle-preview')

        if [ -z "$issue" ]; then
            echo "Cancelled."
            return 0
        fi

        local issue_number issue_title
        issue_number=$(echo "$issue" | sed 's/^#\([0-9]*\) .*/\1/')
        issue_title=$(echo "$issue" | sed 's/^#[0-9]* //')

        # タイトルをブランチ名に変換
        local sanitized_title
        sanitized_title=$(echo "$issue_title" | tr '[:upper:]' '[:lower:]' \
            | sed 's/[[:space:]]/-/g; s/[^a-z0-9-]//g; s/--*/-/g; s/^-//; s/-$//' \
            | cut -c1-50)

        local branch_name="feature/${issue_number}-${sanitized_title}"

        # varedでブランチ名を編集可能に
        echo "Branch name (edit or press Enter to accept):"
        vared -p "> " branch_name

        if [ -z "$branch_name" ]; then
            echo "Cancelled."
            return 0
        fi

        if ! git check-ref-format --branch "$branch_name" 2>/dev/null; then
            echo "Error: Invalid branch name '${branch_name}'." >&2
            return 1
        fi

        # worktreeパスはプレフィックスを除去してフラット配置
        local wt_dirname="${branch_name//\//-}"
        local wt_dir="${wt_base}/${wt_dirname}"

        _gwt_init_worktree "$branch_name" "$wt_dir"
    elif [ -n "$1" ]; then
        # 引数指定モード
        local branch_name="$1"
        local wt_dirname="${branch_name//\//-}"
        local wt_dir="${wt_base}/${wt_dirname}"

        _gwt_init_worktree "$branch_name" "$wt_dir"
    else
        # 引数なし: varedで入力
        local branch_name=""
        vared -p "Branch name> " branch_name

        if [ -z "$branch_name" ]; then
            echo "Cancelled."
            return 0
        fi

        if ! git check-ref-format --branch "$branch_name" 2>/dev/null; then
            echo "Error: Invalid branch name '${branch_name}'." >&2
            return 1
        fi

        local wt_dirname="${branch_name//\//-}"
        local wt_dir="${wt_base}/${wt_dirname}"

        _gwt_init_worktree "$branch_name" "$wt_dir"
    fi
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
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        echo "Error: Not inside a git repository." >&2
        return 1
    }

    # メインworktreeを除外して一覧表示
    local selected
    selected=$(git worktree list | awk -v main="$repo_root" '$1 != main' \
        | fzf --prompt="Remove Worktree> " --header="Select worktree to remove")

    if [ -z "$selected" ]; then
        echo "Cancelled."
        return 0
    fi

    local wt_path
    wt_path=$(echo "$selected" | awk '{print $1}')

    echo "Remove worktree at ${wt_path}? [y/N]"
    read -q "confirm?"
    echo
    if [[ "$confirm" != "y" ]]; then
        echo "Cancelled."
        return 0
    fi
    git worktree remove "$wt_path"
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


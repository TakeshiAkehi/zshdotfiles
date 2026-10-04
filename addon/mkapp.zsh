# AppImage / 実行ファイル / sh からデスクトップエントリを作成する (Superキーの検索に出す)
MKAPP_APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
MKAPP_ICON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons/mkapp"

mkapp() {
    local subcmd="${1:-help}"
    shift 2>/dev/null

    case "$subcmd" in
        add)    _mkapp_add "$@" ;;
        list)   _mkapp_list ;;
        remove) _mkapp_remove "$@" ;;
        *)      _mkapp_help ;;
    esac
}

_mkapp_help() {
    cat <<'EOF'
Usage: mkapp <subcommand>

Subcommands:
  add <file>      Create desktop entry interactively (AppImage / executable / script)
  list            List entries created by mkapp
  remove [name]   Remove entry and its icon (fzf select if omitted, target file is kept)
EOF
}

# [Desktop Entry] セクションから非ローカライズのキーを取得
_mkapp_get() {
    awk -F= -v key="$1" '
        /^\[/ { in_de = ($0 == "[Desktop Entry]"); next }
        in_de && $1 == key { sub(/^[^=]*=/, ""); print; exit }
    ' "$2" 2>/dev/null
}

_mkapp_is_appimage() {
    [[ "$(head -c 11 "$1" 2>/dev/null | tail -c 3 | od -An -c | tr -d ' ')" == 'AI\002' ]] ||
        [[ "${1:l}" == *.appimage ]]
}

# Exec用にパスをクォート (仕様: " ` $ \ をエスケープ, % は %%)
_mkapp_quote_exec() {
    local s="$1"
    s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; s="${s//\`/\\\`}"; s="${s//\$/\\\$}"; s="${s//\%/%%}"
    print -r -- "\"$s\""
}

# 推測値を入れた状態で編集させる. $1=変数名 $2=プロンプト
_mkapp_ask() {
    vared -p "$2> " "$1"
}

_mkapp_yn() {
    local ans default="$2"
    echo -n "$1 [$([[ $default == y ]] && echo Y/n || echo y/N)] "
    read -k 1 ans; [[ "$ans" != $'\n' ]] && echo
    [[ "$ans" == $'\n' || -z "$ans" ]] && ans="$default"
    [[ "$ans" == [yY] ]]
}

# AppImageから .desktop とアイコンを tmp に抽出
_mkapp_extract() {
    local target="$1" tmp="$2"
    (
        builtin cd "$tmp" || exit 1
        "$target" --appimage-extract '*.desktop' >/dev/null 2>&1
        "$target" --appimage-extract '.DirIcon' >/dev/null 2>&1
        local de=(squashfs-root/*.desktop(N))
        local icon_name
        [ -n "$de" ] && icon_name=$(_mkapp_get Icon "$de[1]")
        if [ -n "$icon_name" ]; then
            "$target" --appimage-extract "${icon_name}.png" >/dev/null 2>&1
            "$target" --appimage-extract "${icon_name}.svg" >/dev/null 2>&1
            "$target" --appimage-extract "usr/share/icons/hicolor/*/apps/${icon_name}.*" >/dev/null 2>&1
        fi
        # .DirIcon がシンボリックリンクならリンク先も抽出
        if [ -L squashfs-root/.DirIcon ]; then
            "$target" --appimage-extract "$(readlink squashfs-root/.DirIcon)" >/dev/null 2>&1
        fi
    )
}

# 抽出結果から最適なアイコンを選ぶ (svg > 大きいpng > .DirIcon)
_mkapp_pick_icon() {
    local root="$1" name="$2" f
    if [ -n "$name" ]; then
        for f in "$root/${name}.svg" "$root"/usr/share/icons/hicolor/scalable/apps/"${name}".svg(N); do
            [ -f "$f" ] && { print -r -- "$f"; return; }
        done
        local pngs=("$root"/usr/share/icons/hicolor/*/apps/"${name}".png(N))
        f=$( (( $#pngs )) && print -l $pngs | sort -V | tail -1)
        [ -n "$f" ] && { print -r -- "$f"; return; }
        [ -f "$root/${name}.png" ] && { print -r -- "$root/${name}.png"; return; }
    fi
    f="$root/.DirIcon"
    [ -e "$f" ] && print -r -- "${f:A}"
}

_mkapp_add() {
    local src="$1"
    if [ -z "$src" ] || [ ! -f "$src" ]; then
        echo "Usage: mkapp add <file>" >&2
        return 1
    fi
    src="${src:A}"

    local is_appimage="" kind="executable"
    if _mkapp_is_appimage "$src"; then
        is_appimage=1; kind="AppImage"
    elif [[ "$(head -c 2 "$src")" == '#!' ]]; then
        kind="script"
    fi
    echo "Target: $src ($kind)"

    # 実行権限
    local exec_prefix=""
    if [ ! -x "$src" ]; then
        if _mkapp_yn "Not executable. chmod +x?" y; then
            chmod +x "$src" || return 1
        elif [ "$kind" = script ]; then
            exec_prefix="sh "
        else
            echo "Cancelled."; return 0
        fi
    fi

    # 推測値
    local base="${src:t}"
    local name="${${base%.[Aa]pp[Ii]mage}%.sh}"
    name="${name%%[-_](v|)[0-9]*}"
    local comment="" keywords="" categories="" wmclass="" icon="" args="" workdir=""
    local terminal=n
    [ "$kind" = script ] && terminal=y && workdir="${src:h}"

    local tmp
    tmp=$(mktemp -d -t mkapp.XXXXXX)
    trap "rm -rf ${(q)tmp}" EXIT INT
    if [ -n "$is_appimage" ]; then
        echo "Extracting metadata from AppImage..."
        _mkapp_extract "$src" "$tmp"
        local de=("$tmp"/squashfs-root/*.desktop(N))
        if [ -n "$de" ]; then
            local v
            v=$(_mkapp_get Name "$de[1]");           [ -n "$v" ] && name="$v"
            comment=$(_mkapp_get Comment "$de[1]")
            keywords=$(_mkapp_get Keywords "$de[1]")
            categories=$(_mkapp_get Categories "$de[1]")
            wmclass=$(_mkapp_get StartupWMClass "$de[1]")
            [[ "$(_mkapp_get Terminal "$de[1]")" == true ]] && terminal=y
            icon=$(_mkapp_pick_icon "$tmp/squashfs-root" "$(_mkapp_get Icon "$de[1]")")
        else
            icon=$(_mkapp_pick_icon "$tmp/squashfs-root" "")
        fi
    fi
    [ -z "$icon" ] && icon="application-x-executable"

    echo
    echo "Edit each field (Enter to accept, empty to omit)."
    _mkapp_ask name       "Name"
    [ -z "$name" ] && { echo "Name is required."; return 1; }
    _mkapp_ask comment    "Comment"
    _mkapp_ask keywords   "Keywords (;-separated, used by search)"
    _mkapp_ask args       "Arguments (e.g. --no-sandbox %%U)"
    _mkapp_ask workdir    "Working directory"
    _mkapp_ask wmclass    "StartupWMClass"
    _mkapp_ask icon       "Icon (file path or theme icon name)"
    if _mkapp_yn "Run in terminal?" "$terminal"; then terminal=true; else terminal=false; fi

    local cat_sel
    cat_sel=$(print -l AudioVideo Audio Video Development Education Game Graphics Network Office Science Settings System Utility |
        fzf --multi --prompt="Categories> " --header="TAB: multi-select / Esc: keep '${categories:-none}'")
    [ -n "$cat_sel" ] && categories="${(j:;:)${(f)cat_sel}};"

    # ファイル名
    local slug=$(print -r -- "${name:l}" | sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//')
    _mkapp_ask slug "File id (mkapp-<id>.desktop)"
    [ -z "$slug" ] && { echo "Id is required."; return 1; }
    local desktop="$MKAPP_APP_DIR/mkapp-${slug}.desktop"

    # アイコン: ファイルなら mkapp 用ディレクトリへコピー
    local icon_value="$icon"
    if [ -f "$icon" ]; then
        local ext
        case "$(file -bL --mime-type "$icon")" in
            image/svg+xml) ext=svg ;;
            image/png)     ext=png ;;
            image/jpeg)    ext=jpg ;;
            *)             ext="${icon:e}"; [ -z "$ext" ] && ext=png ;;
        esac
        icon_value="$MKAPP_ICON_DIR/${slug}.${ext}"
    fi

    local exec_line="${exec_prefix}$(_mkapp_quote_exec "$src")${args:+ $args}"
    local content
    content=$(cat <<EOF
[Desktop Entry]
Type=Application
Name=$name
${comment:+Comment=$comment
}Exec=$exec_line
Icon=$icon_value
Terminal=$terminal
${workdir:+Path=$workdir
}${categories:+Categories=$categories
}${keywords:+Keywords=$keywords
}${wmclass:+StartupWMClass=$wmclass
}X-Mkapp-Source=$src
EOF
)

    echo
    echo "----- $desktop -----"
    print -r -- "$content"
    echo "------------------------------------------------------------"
    [ -e "$desktop" ] && echo "WARN: $desktop already exists and will be overwritten."

    local ans
    echo -n "Save? [Y/n/e] (e=edit in \$EDITOR) "
    read -k 1 ans; [[ "$ans" != $'\n' ]] && echo
    if [[ "$ans" == [eE] ]]; then
        local draft="$tmp/draft.desktop"
        print -r -- "$content" > "$draft"
        ${EDITOR:-vi} "$draft"
        content=$(<"$draft")
    elif [[ "$ans" != [yY] && "$ans" != $'\n' ]]; then
        echo "Cancelled."; return 0
    fi

    mkdir -p "$MKAPP_APP_DIR" "$MKAPP_ICON_DIR"
    [ -f "$icon" ] && cp -L "$icon" "$icon_value"
    print -r -- "$content" > "$desktop"
    chmod +x "$desktop"

    command -v desktop-file-validate &>/dev/null && desktop-file-validate "$desktop"
    command -v update-desktop-database &>/dev/null && update-desktop-database "$MKAPP_APP_DIR" 2>/dev/null
    echo "Created: $desktop"
}

_mkapp_entries() {
    local f
    for f in "$MKAPP_APP_DIR"/mkapp-*.desktop(N); do
        local src=$(_mkapp_get X-Mkapp-Source "$f")
        local mark="ok"; [ -e "$src" ] || mark="MISSING"
        printf '%s\t%s\t%s\t%s\n' "${${f:t:r}#mkapp-}" "$(_mkapp_get Name "$f")" "$mark" "$src"
    done
}

_mkapp_list() {
    local entries=$(_mkapp_entries)
    [ -z "$entries" ] && { echo "No entries."; return 0; }
    { echo "ID\tNAME\tSTATUS\tSOURCE"; print -r -- "$entries"; } | column -t -s $'\t'
}

_mkapp_remove() {
    local ids=()
    if [ -n "$1" ]; then
        ids=("$@")
    else
        local sel
        sel=$(_mkapp_entries | column -t -s $'\t' | fzf --multi --prompt="Remove> " --header="TAB: multi-select")
        [ -z "$sel" ] && return 0
        ids=(${(f)"$(print -r -- "$sel" | awk '{print $1}')"})
    fi

    local id desktop icon
    for id in $ids; do
        desktop="$MKAPP_APP_DIR/mkapp-${id}.desktop"
        [ -f "$desktop" ] || { echo "Not found: $id"; continue; }
        _mkapp_yn "Remove '$(_mkapp_get Name "$desktop")' ($desktop)?" n || continue
        icon=$(_mkapp_get Icon "$desktop")
        [[ "$icon" == "$MKAPP_ICON_DIR"/* ]] && rm -f "$icon"
        rm -f "$desktop"
        echo "Removed: $id"
    done
    command -v update-desktop-database &>/dev/null && update-desktop-database "$MKAPP_APP_DIR" 2>/dev/null
}

_mkapp_complete() {
    if (( CURRENT == 2 )); then
        compadd add list remove
    elif [[ "$words[2]" == add ]]; then
        _files
    elif [[ "$words[2]" == remove ]]; then
        compadd ${${(f)"$(_mkapp_entries | cut -f1)"}}
    fi
}
(( $+functions[compdef] )) && compdef _mkapp_complete mkapp

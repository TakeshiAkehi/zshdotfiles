# Claude Code statusline (dotfiles/.claude/statusline.sh) を ~/.claude/settings.json に登録
# statusline.sh本体のリンクは 2_link_dotfiles.bash が行う
if ! type jq >/dev/null 2>&1; then
    sudo apt install -y jq
fi

SETTINGS="${HOME}/.claude/settings.json"
mkdir -p "$(dirname "${SETTINGS}")"
[ -s "${SETTINGS}" ] || echo '{}' > "${SETTINGS}"

tmp=$(mktemp)
jq '.statusLine = {"type": "command", "command": "bash ~/.claude/statusline.sh", "padding": 0}' \
    "${SETTINGS}" > "${tmp}" && mv "${tmp}" "${SETTINGS}"
echo "registered statusLine in ${SETTINGS}"

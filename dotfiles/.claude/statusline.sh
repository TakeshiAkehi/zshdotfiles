#!/usr/bin/env bash
# Claude Code statusline: model | dir (git branch) | context usage bar
# stdinにClaude CodeからセッションJSONが渡される

input=$(cat)

j() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }

model=$(j '.model.display_name')
cwd=$(j '.workspace.current_dir')
[ -z "$cwd" ] && cwd=$(j '.cwd')
transcript=$(j '.transcript_path')

# --- context usage ---
size=$(j '.context_window.context_window_size')
[ -z "$size" ] && size=200000
pct=$(j '.context_window.used_percentage')
used=$(jq -r '.context_window.current_usage
  | if . == null then empty else
      (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
    end' <<<"$input" 2>/dev/null)

# 古いバージョン向けフォールバック: transcriptの最後のusageから計算
if [ -z "$used" ] && [ -n "$transcript" ] && [ -f "$transcript" ]; then
    used=$(tail -n 200 "$transcript" | jq -rs '
      [ .[] | select(.isSidechain != true) | .message.usage? | select(. != null) ] | last
      | if . == null then empty else
          (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
        end' 2>/dev/null)
fi
[ -z "$used" ] && used=0
if [ -z "$pct" ]; then
    pct=$(( used * 100 / size ))
fi
pct=${pct%.*}

# 色: <50% 緑, <80% 黄, それ以上 赤
if   [ "$pct" -lt 50 ]; then color=$'\e[32m'
elif [ "$pct" -lt 80 ]; then color=$'\e[33m'
else                         color=$'\e[31m'
fi
reset=$'\e[0m'
dim=$'\e[2m'

width=10
filled=$(( pct * width / 100 ))
[ "$filled" -gt "$width" ] && filled=$width
bar=""
for ((i = 0; i < width; i++)); do
    if [ "$i" -lt "$filled" ]; then bar+="█"; else bar+="░"; fi
done

human() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        awk -v n="$n" 'BEGIN { printf "%.1fM", n / 1000000 }'
    elif [ "$n" -ge 1000 ]; then
        printf '%dk' $(( n / 1000 ))
    else
        printf '%d' "$n"
    fi
}

ctx="${color}${bar} ${pct}%${reset} ${dim}($(human "$used")/$(human "$size"))${reset}"

# --- dir / git branch ---
dir=${cwd/#$HOME/\~}
branch=""
if [ -n "$cwd" ]; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi
loc="\e[34m${dir}${reset}"
[ -n "$branch" ] && loc+=" \e[35m(${branch})${reset}"

printf '%b' "\e[36m${model}${reset} │ ${loc} │ ${ctx}"

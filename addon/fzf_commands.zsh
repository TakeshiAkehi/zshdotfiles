
# fzfで選択したコマンドを実行/実行履歴に追加
__dot::exec(){
    echo "$1"
    # macはhistoryコマンドじゃなかったっけなあ.手元ではprintで動く
    # if [ "$(uname)" = 'Darwin' ]; then
        # history -s "$1"
    # else
        print -s "$1"
    # fi
    eval "$1"
}

awsfz() {
  local profile=$(grep -o -P '(?<=\[profile )[^\]]+' ~/.aws/config  | sed "/default/d" | sort | fzf )
  local CMD="export AWS_PROFILE=$profile"
  __dot::exec "${CMD}"
}




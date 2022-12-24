
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
  if [ "$(uname)" = 'Darwin' ]; then
    if type "ggrep" > /dev/null 2>&1; then 
        # 早い. 下記必要 
        ## brew install coreutils
        ## brew install gnu-sed
        local profile=$(ggrep -o -P '(?<=\[profile )[^\]]+' ~/.aws/config  | sed "/default/d" | sort | fzf )
    else
        # 遅い
        local profile=$(aws configure list-profiles | sort | fzf )
    fi
  else
    local profile=$(grep -o -P '(?<=\[profile )[^\]]+' ~/.aws/config  | sed "/default/d" | sort | fzf )
  fi
  local CMD="export AWS_PROFILE=$profile"
  __dot::exec "${CMD}"
}




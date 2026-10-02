## 推奨要件

ターミナル側のフォント設定を先にやっておくと良い．

* MesloLGS NFフォントのインストール
* 使用してるターミナル側(vscodeなど)で使用フォントを設定

詳細手順は下記リンク参照のこと
https://github.com/romkatv/powerlevel10k#manual-font-installation

## 使い方

見た目カスタム
```
p10k configure
```

現在のgitブランチが表示される
```
cd zshdotfiles
```

gitサブコマンドの補完
```
git che<tab>
```

存在しないコマンドは赤で，存在するコマンド緑で表示される
```
aw (赤)
aws (緑)
```

最近使用したフォルダへのインタラクティブ移動
```
cd
```

最近使用したコマンドのインタラクティブ選択
```
<ctrl>-r
```

zellijのセッション管理サイドバー (zellij-choose-tree)
```
<Alt>-s        現在のタブの左端にセッションツリーをフローティングで表示 / 非表示 (ペイン配置は崩れない)
  j/k h/l      移動 / 折りたたみ・展開
  Enter, 0-9   セッション・タブ・ペインへ移動 (サイドバーは閉じる)
  s            直前に使っていたセッションへ移動
  r            カーソル位置のセッションをリネーム (名前を編集してEnter, Escで取消)
  n            新規セッションを作成して移動 (名前を入力してEnter, 空ならランダム名, Escで取消)
  x            選択セッションを終了
  Esc          サイドバーを閉じる
```
初回はzellij起動時にプラグインの権限確認が出るので `y` で許可する．
プラグインは `installer/zellij-choose-tree.bash` がパッチ (`installer/zellij-choose-tree/sidebar.patch`) を当ててビルドし `~/.config/zellij/plugins/` に配置する．

Claude Codeのstatusline (モデル │ ディレクトリ(gitブランチ) │ コンテキスト使用量)
```
Opus 5.5 │ ~/soft/zshdotfiles (main) │ █████░░░░░ 57% (115k/200k)
```
使用率は 50%未満 緑 / 80%未満 黄 / それ以上 赤．
本体は `dotfiles/.claude/statusline.sh` (2_link_dotfiles.bashで `~/.claude/statusline.sh` にリンク)，
`~/.claude/settings.json` への登録は `installer/claude-statusline.bash` が行う．

## install

```
git clone https://github.com/TakeshiAkehi/zshdotfiles.git
bash zshdotfiles/1_install.bash
bash zshdotfiles/2_link_dotfiles.bash
bash zshdotfiles/3_enable_dotrc.bash
exec /bin/zsh -l
```

### uninstall

* 1_install.bash
  * aptで自力アンインストール
* 2_link_dotfiles.bash
  * bkupに元々$HOMEにあったファイルがあるので元の場所に戻す
* 3_enable_dotrc.bash
  * ~/.zshrcの`source <このリポジトリのディレクトリ>/dotrc.zsh`の記述を消す

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

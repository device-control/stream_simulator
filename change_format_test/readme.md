StreamSimulator マニュアル
===============================

環境構築
-------------------------------
前提条件：ここでの説明は全て Windows7(64 bit) 環境を想定

本ツールを動作させるにはrubyをインストールする必要がある。
ruby 環境を整えるには、ruby 本体と Devkit のインストールが必要であり
下表通りに構築する。

|No|インストールするもの|インストール先|インストーラ|
|:---:| --------------- | --------------- | --------------- |
| 1 | Ruby2.1.7(32bit) | c:\Ruby\217 | [rubyinstaller-2.1.7.exe](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.1.7.exe) |
| 2 | DevKit | c:\Ruby\devkit\200 | [DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe](http://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe) |
| 3 | bundler | ruby インストール先 | ruby gem コマンドでインストール |
* Ruby のバージョンは、2016/1/15 現在 "Ruby 2.1.7" が最新 
* Devkitは、ruby ライブラリ(gem)をインストールするのに必要
* bundler は ruby gem を便利にインストールするためのコマンド

以下にruby環境を構築する手順を示す。

### Ruby 環境構築

#### Ruby インストール手順
1. [RubyInstaller for Windows](http://rubyinstaller.org/)から[ruby 2.1.7](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.1.7.exe)のインストーラをダウンロードする
* ダウンロードサイト
http://rubyinstaller.org/downloads/
* 対象ファイル
rubyinstaller-2.1.7.exe
2. rubyinstaller-2.1.7.exe を実行する
インストール時の問い合わせは以下の内容を参考になる。
* インストール先は、上記の表参照すること
* 使用許諾契約書の同意には”同意する”にチェックを入れ"次へ"を押下
* インストール先とオプションの指定はすべてにチェックを入れておくと便利
* Td/Tk は GUI スクリプトを動作させる場合に必要（今回不用）
* 環境変数 PATH を設定しておかないと、コマンドラインからrubyが利用できない
* .rb, .rbw ファイルを rubyに関連づけておくとダブルクリップ等でrubyスクリプトが起動可能

#### DevKit インストール手順
1. [RubyInstaller for Windows](http://rubyinstaller.org/)から[DevKit 2.0(32bit)](http://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe)のインストーラをダウンロードする
* ダウンロードサイト
http://rubyinstaller.org/downloads/
* 対象ファイル
DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe
(DEVELOPMENT KIT For use with Ruby 2.0 and above (32bits version only))
2. DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe を実行する
* 7-Zip self-extracting archive で指定するパスがインストール先となる
* インストール先は、上記の表を参照すること
3. Ruby 2.1.7 と DevKit を紐づける
コマンドプロンプトより以下を実施する
```DOS .bat(dos)
> cd c:\Ruby\devkit\200
> ruby dk.rb init
> ruby dk.rb review
Based upon the settings in the 'config.yml' file generated
from running 'ruby dk.rb init' and any of your customizations,
DevKit functionality will be injected into the following Rubies
when you run 'ruby dk.rb install'.
C:/Ruby/217 <--- ここがインストールしたrubyのパスになっていること。
> ruby dk.rb install
```

#### bunndler をインストールする手順
コマンドプロンプトより以下を実施する
```DOS .bat(dos)
 > gem install bundler
```

StreamSimulator 設置
-------------------------------

StreamSimulator の設置手順を以下に示す。
なお、設置場所は以下の通りとする

|設置場所|C:\tools\StreamSimulator|
|:----:|:----|
|||

1. 本github環境を設置場所に配置する
2. StreamSimulatorが必要な ruby gem をインストールする
以下に操作手順をまとめておく。
コマンドプロンプトより以下を実施

```DOS .bat(dos)
# git クローン（クローンせずにzipファイルをダウンロードし手動で展開してもよい）
> cd C:\tools
> git clone https://github.com/device-control/stream_simulator.git
# C:\tools\stream_simulator が生成されているはず 
> cd C:\tools\StreamSimulator
> bundle install 
```



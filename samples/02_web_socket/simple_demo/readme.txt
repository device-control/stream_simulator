使い方：

ターミナルで動作確認する方法
1: server を起動する（エコー）
$ ruby websocket_server.rb

2: client を pry で実行する
$ pry -r ./websocket_client.rb
# $c0 に client インスタンスが設定される
> $c0.open
> $c0.write "string"
> $c0.write_binary "binary"
> $c0.close


html で動作確認する方法
1: server を起動する（エコー）
$ ruby websocket_server.rb

2: web サイトを起動
$ cd ../singlepage_demo
# gulp がインストールされていること
$ gulp 
ブラウザで localhost:8000 にアクセスし websocket 欄を選択する

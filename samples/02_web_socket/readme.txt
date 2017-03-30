各フォルダの説明を記載する
(1) simple_demo
    単純なwebsocketの動作確認スクリプト。
    stream_websocket_server,stream_websocket_client クラスとは関係なく
    websokcetの動作確認用スクリプトである。

(2) singlepage_demo
    (1)のwebsocket_server.rbを利用してhtmlクライアントで接続確認を行うデモ
    websocket_server.rbはlocalhost:8888 で待ち受けており、受信メッセージを
    そのまま返すことのみを行うサーバ。（エコーサーバ）

(3) stream_websocket_server
    stream_websocket_server クラスの動作確認用スクリプト
    利用データは(4)stream_dataを使用

(4) stream_data
    (3) stream_websocket_serverが利用するデータ群

※(3)(4)の対向のclientは現状未実装。。。
### 03_serial

---

com0comで仮想のシリアルペア'COM3'と'COM4'を作成し、COM3とCOM4にそれぞれ接続し、メッセージの送受信を行うサンプル

#### 前提条件

---

com0com で 'COM3'と'COM4' の仮想シリアルペアを作成しておく


#### 操作手順

---

1.COM3側を起動する 
* /01_serial/com3/execute_stream_simulator.bat を実行 
* 実行したコマンドプロンプトにて、 *start* を実行する

2.COM4側を起動する
* /01_serial/com4/execute_stream_simulator.bat を実行 
* 実行したコマンドプロンプトにて、 *start* を実行する

※接続ができれば、以下のようなログが表示されます。

    通知:StubMain:stream_coonected: シリアルCOM X

3.COM4からメッセージを送信する
* COM4のコマンドプロンプトにて、以下のコマンドを実行する

*write "1001123412345678FEDCBA98"*

メッセージが送信できれば、COM3側にログが表示される。

4.COM3からメッセージを送信する
* COM3のコマンドプロンプトにて、以下のコマンドを実行する

*$ write "1001123412345678FEDCBA98"*

メッセージが送信できれば、COM4側にログが表示されます。

#### 補足

---

* メッセージの一覧を表示したい場合、以下のコマンドを実行する

*$ show_message*

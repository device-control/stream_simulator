// websocket 接続確認
// document.addEventListener("pageinit", function(e) {
  // if (e.target.id == "websocket_page") {
    var ws = null;
    document.getElementById('websocket_status').innerHTML = "切断";
    // 接続
    function websocket_open() {
      if (ws == null) {
        // WebSocket の初期化
        ip = document.getElementById('websocket_ip').value;
        port = document.getElementById('websocket_port').value;
        ws = new WebSocket("ws://" + ip +":" + port);
        // イベントハンドラの設定
        ws.onopen = onOpen;
        ws.onmessage = onMessage;
        ws.onclose = onClose;
        ws.onerror = onError;
        document.getElementById('websocket_status"').innerHTML = "接続中...";
      }
    }

    function websocket_send() {
      if (ws == null) return;
      message = document.getElementById('websocket_message').value;
      ws.send(message);
    }
  
    function onOpen(event) {
      console.log("接続した");
      document.getElementById('websocket_status').innerHTML = "接続";
      ws.send("開始");
    }

    function onClose(event) {
      console.log("切断した");
      document.getElementById('websocket_status').innerHTML = "切断";
      ws = null;
    }

    function onError(event) {
      console.log("エラー発生");
      document.getElementById('websocket_status').innerHTML = "ERROR";
      
      var message_li = document.createElement("li");
      message_li.textContent = "エラー発生"
      document.getElementById("websocket_error").appendChild(message_li);
    }
    
    function onMessage(event){
      console.log("メッセージ受信");
      var message_li = document.createElement("li");
      message_li.textContent = event.data
      document.getElementById("websocket_receive_message").appendChild(message_li);
    }
    // websocket_open();
  // }
// }, false);

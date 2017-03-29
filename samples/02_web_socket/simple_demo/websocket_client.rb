# coding: utf-8
require 'websocket-client-simple'
Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class WebSocketClient
  attr_reader :name, :ip, :port, :timeout, :ws
  
  def initialize(name, ip, port, timeout)
    super()
    @name = name
    @ip = ip
    @port = port
    @timeout = timeout
    @ws = nil
  end
  
  def open
    this = self
    @ws = WebSocket::Client::Simple::Client.new
    @ws.on :message do |msg|
      # メッセージ受信
      this.message_event msg.data
    end
    # ws.on :open &open_event
    @ws.on :open do
      # 接続
      this.open_event
      #notify_connect # オープン通知
    end
    @ws.on :close do |emsg|
      # 切断
      this.close_event
    end
    @ws.connect "ws://#{@ip}:#{@port}"
  end
  
  def close
    @ws.close
    @ws = nil
  end
  
  def write(message)
    @ws.send message
  end
  
  def write_binary(message)
    @ws.send message, :type => :binary
  end

  def open_event
    p "[EVENT] open:"
  end
  def close_event
    p "[EVENT] close:"
  end
  def message_event(msg)
    p "[EVENT] message : " + msg
  end
end

$c0 = WebSocketClient.new "client", "127.0.0.1", 8888, 1

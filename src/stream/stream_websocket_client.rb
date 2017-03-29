# coding: utf-8

require 'websocket-client-simple'
require "stream/stream_observer"
require "log"

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamWebSocketClient
  include StreamObserver
  attr_reader :name, :ip, :port, :timeout, :opened, :ws
  
  def initialize(name, ip, port, timeout)
    super()
    @name = name
    @ip = ip
    @port = port
    @timeout = timeout
    @ws = nil
    @opened = false
  end
  
  def open
    return if @opened == true
    this = self
    # client 生成
    begin
      @ws = WebSocket::Client::Simple::Client.new
      @ws.on :open do # = ws.on :open &open_event
        this.open_event # 接続
      end
      @ws.on :close do |emsg|
        this.close_event # 切断
      end
      @ws.on :message do |msg|
        this.message_event msg # 受信(バイナリ含む)
      end
    rescue => e
      Log.instance.error "StreamWebSocketClient#open: rescue: "+e.message
      raise "StreamWebSocketClient::open: error: "+e.message
      return
    end
    # 接続
    retry_count = (@timeout / 10000) + 1
    retry_count.times do |index|
      begin
        @ws.connect "ws://#{@ip}:#{@port}"
        break
      rescue => e
        if( index == (retry_count - 1) )
          Log.instance.error "StreamWebSocketClient#open: rescue: "+e.message
          raise "StreamWebSocketClient::open: error: "+e.message
          return
        end
        sleep 1
      end
    end
    @opened = true
  end
  
  def close
    return if @opened == false
    @ws.close
    @ws = nil
    @opened = false
    #notify_disconnect # クローズ通知
  end
  
  def write(message)
    return if @opened == false
    @ws.send message, :type => :binary # 送信データはバイナリーとする
  end

  def open_event
    notify_connect
  end
  def close_event
    notify_disconnect
  end
  def message_event(msg)
    notify_message msg.data
  end
end

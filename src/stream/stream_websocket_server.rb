# coding: utf-8

require 'em-websocket'
require "stream/stream_observer"
require "log"
require 'pry'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamWebSocketServer
  include StreamObserver
  
  attr_reader :name, :ip, :port, :timeout, :opened
  
  def initialize(name, ip, port, timeout)
    super()
    @name = name
    @ip = ip
    @port = port
    @timeout = timeout
    
    @current_socket = nil
    @send_queue = Queue.new
    
    @opened = false
    @connected = false
  end
  
  def open
    return if @opened == true
    @opened = true
    # EventMachineを別スレッドで生成
    begin
      @thread = Thread.new {
        EM.run {
          # 送信用のスレッドを生成
          EM.defer {
            while message = @send_queue.pop
              EM.next_tick do
                # バイナリで送信する
                # _send_data(message)
                _send_binary(message)
              end
            end
          }
          
          # WebSocket実行
          EM::WebSocket.start(:host => @ip, :port => @port) { |ws|
            ws.onopen { |handshake| _onopen(ws, handshake) }
            ws.onclose { _onclose(ws) }
            ws.onmessage { |msg| _onmessage(ws, msg) }
            ws.onbinary { |msg| _onbinary(ws, msg) }
            
            @current_socket.close if @current_socket
            @current_socket = ws
            @connected = false
          }
        }
      }
    rescue => e
      Log.instance.error "StreamWebSocketServer#open: error" + e.messaeg
      raise "StreamWebSocketServer#open: error: " + e.message
    end
  end
  
  def close
    return if @opened == false
    EM.stop_event_loop
    @thread.kill
    @thread.join
    @thread = nil
  end
  
  def write(message)
    @send_queue.push(message)
  end
  
  def _onopen(ws, handshake)
    if @current_socket == ws
      Log.instance.debug "StreamWebSocketServer: clinet connected"
      @connected = true
      notify_connect
    end
  end
  
  def _onclose(ws)
    if @current_socket == ws
      Log.instance.debug "StreamWebSocketServer: client disconnect"
      @connected = false
      notify_disconnect
      @current_socket = nil
    end
  end
  
  def _onbinary(ws, binary)
    if @current_socket == ws
      notify_message(binary)
      Log.instance.debug "StreamTCPServer: receive: " + binary
    end
  end
  
  def _send_binary(binary)
    @current_socket.send_binary(binary) if @current_socket
  end
end

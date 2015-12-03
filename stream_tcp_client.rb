# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "socket"
require "stream_observer"
require "log"

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamTCPClient
  include StreamObserver

  attr_reader :name, :ip, :port, :timeout

  def initialize(name, ip, port, timeout)
    super()
    @name = name
    @ip = ip
    @port = port
    @timeout = timeout
    
    @socket = nil
    @opened = false
  end

  def receive
    log = Log.instance
    begin
      connected = true
      while connected
        sel = IO::select([@socket], nil, nil, @timeout)
        if sel
          sel[0].each do | s |
            data = s.recv(65535)
            if data.length > 0
              log.debug "StreamTCPClient#receive: " + data
              notify_message data # 受信通知
            else
              # サーバが切断した
              log.debug "StreamTCPClient#receive: disconnect"
              connected = false
              notify_disconnect # 切断通知
            end
          end
        end
      end
    rescue => e
      log.error "StreamTCPClient#receive: rescue: "+e.message
    ensure
      log.debug "StreamTCPClient#receive: ensure"
      @socket.close if @socket
      @socket = nil
      @opened = false
    end
    log.debug "StreamTCPClient#receive: end"
  end
  
  # 本メソッドが正常に実施された場合、 server,client 共に接続通知される
  def open
    return if @opened
    begin
      @socket = TCPSocket.open(@ip, @port)
      @receive_thread = Thread.new(&method(:receive))
      @opened = true
      notify_connect # 接続通知
    rescue => e
      @socket.close if @socket
      @socket = nil
      raise "StreamTCPClient::open: error: "+e.message
    # ensure
    #   puts "StreamTCPClient: ensure"
    end
  end

  def write(message)
    return if !@opened
    @socket.send(message,0)
  end

  # 本メソッドが正常に実施された場合、 server 側は client の切断が通知される
  # * 自身(client) は close を呼び出したことで切断をしる（通知されない）
  def close
    return if !@opened
    @receive_thread.kill
    @receive_thread.join
    @receive_thread = nil
    @socket.close if @socket
    @socket = nil
    
    @opened = false
  end
  
end

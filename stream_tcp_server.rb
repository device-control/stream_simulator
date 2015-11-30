# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "socket"
require "stream_observer"
require "log"

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 参考URL
# Geek なぺーじ: Rubyネットワークプログラミング > IO::selectを使う
# http://www.geekpage.jp/programming/ruby-network/select-0.php

class StreamTCPServer
  include StreamObserver

  attr_reader :name, :ip, :port, :timeout

  def initialize(name, ip, port, timeout)
    super()
    @name = name
    @ip = ip
    @port = port
    @timeout = timeout
    
    @server = nil
    @socket = nil
    @receive_thread = nil
    @opened = false
    @connected = false
  end

  def receive
    log = Log.instance
    begin
      loop do # 接続待ち
        @socket = @server.accept # 接続待ち
        log.debug "StreamTCPServer: clinet connected!!"
        @connected = true
        notify_connect # 接続通知
        while @connected # 受信待ち
          sel = IO::select([@socket], nil, nil, timeout)
          if sel
            sel[0].each do | s |
              data = s.recv(65535)
              if data.length > 0
                log.debug "StreamTCPServer: receive: " + data
                notify_message data # 受信通知
              else
                log.debug "StreamTCPServer: client disconnect"
                # クライアントが切断した
                @connected = false
                notify_disconnect # 切断通知
              end
            end
          end
        end
      end
    rescue => e
      log.error "StreamTCPServer#receive: rescue: "+e.message
    ensure
      log.debug "StreamTCPServer#receive: ensure"
      @socket.close if @socket
      @socket = nil
      @server.close if @server
      @server = nil
      @opened = false
    end
    puts "StreamTCPServer#receive: end"
  end

  # ソケットオープンしてclientを待ち受ける
  # 通知はなにもされない
  def open
    return if @opened
    begin
      @server = TCPServer.open(@ip, @port)
      @receive_thread = Thread.new(&method(:receive))
      @opened = true
    rescue => e
      @server.close if @server
      @server = nil
      raise "StreamTCPServer::open: error: "+e.message
    # ensure
    #   puts "StreamTCPServer#open: ensure"
    end
  end

  # opened だけでは client が接続してないので connected 時だけ write できる
  def write(message)
    return if !@connected
    @socket.send(message,0)
  end

  # 本メソッドが正常に実施された場合、client 側は server の切断が通知される
  # * 自身(server) は close を呼び出したことで切断をしる（通知されない）
  def close
    return if !@opened
    @receive_thread.kill
    @receive_thread.join
    @receive_thread = nil
    @socekt.close if @socket
    @socket = nil
    @server.close if @server
    @server = nil
    
    @opened = false
  end
  
end

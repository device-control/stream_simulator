# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "stream_tcp_server"
require "stream_tcp_client"

require "stream_setting"
require "Stream_manager"

require "pry"

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'


class StubMain
  attr_reader :tcp_server_stream, :tcp_client_stream, :connects, :messages
  
  def initialize
    # server
    @tcp_server_parameters = StreamSetting.load "setting_tcp_server.yml"
    @tcp_server_stream = StreamManager.create @tcp_server_parameters
    # client
    @tcp_client_parameters = StreamSetting.load "setting_tcp_client.yml"
    @tcp_client_stream = StreamManager.create @tcp_client_parameters

    @connects = 0
    @messages = 0
  end

  def add_observer
    @tcp_server_stream.add_observer StreamObserver::STATUS, self
    @tcp_server_stream.add_observer StreamObserver::MESSAGE, self
    
    @tcp_client_stream.add_observer StreamObserver::STATUS, self
    @tcp_client_stream.add_observer StreamObserver::MESSAGE, self
  end

  # 接続通知
  def stream_connected(stream)
    puts "通知:StubMain:stream_coonected: " + stream.name
    @connects += 1
  end

  # 切断通知
  def stream_disconnected(stream)
    puts "通知:StubMain:stream_discoonected: " + stream.name
    @connects -= 1
  end

  # 受信通知
  def stream_message_received(stream,message)
    puts "通知:StubMain:message_received: " + stream.name + " : " + message
    @messages += 1
  end
end

@stubmain = StubMain.new
@stubmain.add_observer

# 接続
puts "--- 接続 ---"
@stubmain.tcp_server_stream.open
@stubmain.tcp_client_stream.open

# 接続するまで待つ
while @stubmain.connects != 2
  puts "connecting wait...#{@stubmain.connects}"
  sleep 1
end

# メッセージ送信
puts "--- 送信 ---" 
@stubmain.tcp_server_stream.write "server to client message"
@stubmain.tcp_client_stream.write "client to server message"

# 受信するまで待つ
while @stubmain.messages != 2
  puts "recevie message wait...#{@stubmain.messages}"
  sleep 1
end

# 切断
puts "--- 切断 ---" 
@stubmain.tcp_client_stream.close
# clientが切断するまで待つ
while @stubmain.connects != 1
  puts "closing wait...#{@stubmain.connects}"
  sleep 1
end
@stubmain.tcp_server_stream.close

puts "終了"


# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'stream/stream_websocket_server'
require 'stream/stream_websocket_client'
require 'stream/stream_observer'
require 'log'

require 'pry'

class MockListener
  attr_reader :name, :connects, :recv_messages, :recv_message
  
  def initialize(name)
    @name = name
    @connects = 0
    @recv_messages = 0
    @recv_message = nil
  end
  
  # 接続通知
  def stream_connected(stream)
    # server:クライアントが接続してきた時
    # client:クライアントが正しく接続できた時
    
    # puts "接続通知(#{@name}):" + stream.name
    @connects += 1
  end

  # 切断通知
  def stream_disconnected(stream)
    # server:クライアントが切断してきた時
    # client:サーバが切断してきた時
    
    # puts "切断通知(#{@name}): " + stream.name
    @connects -= 1
  end

  # 受信通知
  def stream_message_received(stream,message)
    # server:クライアントからメッセージを受信してきた時
    # client:サーバからのメッセージを受信した時
    
    # puts "受信通知(#{@name}): " + stream.name + " : " + message
    @recv_messages += 1
    @recv_message = message
  end
end


describe 'StreamWebSocketServer' do
  before do
    log = Log.instance
    log.disabled
  end
  
  context '生成' do
    # before do
    #   @tcp_server_stream = StreamTCPServer.new 'server', '127.0.0.1', 50000, 5
    # end
    it '正しく生成されることを確認' do
      server = StreamWebSocketServer.new 'server', '127.0.0.1', 8888, 5
      expect(server.name).to eq 'server'
      expect(server.ip).to eq '127.0.0.1'
      expect(server.port).to eq 8888
      expect(server.timeout).to eq 5
      server.close
    end
  end

  context 'オープン' do
    it 'クライアントが接続できるか確認' do
      server_listener = MockListener.new 'server'
      client_listener = MockListener.new 'client'
      
      server = StreamWebSocketServer.new 'server', '127.0.0.1', 8888, 5
      client = StreamWebSocketClient.new 'client', '127.0.0.1', 8888, 5
      
      server.add_observer StreamObserver::STATUS,  server_listener
      server.add_observer StreamObserver::MESSAGE, server_listener
      client.add_observer StreamObserver::STATUS,  client_listener
      client.add_observer StreamObserver::MESSAGE, client_listener
      expect{server.open}.not_to raise_error # expect がブロック呼び出しになっていることに注意
      expect{client.open}.not_to raise_error
      
      # 接続待ち(max 10sec)
      10.times do
        break if server_listener.connects != 0 && client_listener.connects != 0
        sleep 1
      end
      expect(server_listener.connects).to eq 1
      expect(client_listener.connects).to eq 1
      client.close
      server.close
    end

    it '２重にオープンしてもエラーとならないことを確認' do
      server_listener = MockListener.new 'server'
      client_listener = MockListener.new 'client'
      
      server = StreamWebSocketServer.new 'server', '127.0.0.1', 8888, 5
      client = StreamWebSocketClient.new 'client', '127.0.0.1', 8888, 5
      
      server.add_observer StreamObserver::STATUS,  server_listener
      server.add_observer StreamObserver::MESSAGE, server_listener
      client.add_observer StreamObserver::STATUS,  client_listener
      client.add_observer StreamObserver::MESSAGE, client_listener
      # １回目のオープン
      expect{server.open}.not_to raise_error # expect がブロック呼び出しになっていることに注意
      expect{client.open}.not_to raise_error

      # ２回目のオープン
      expect{server.open}.not_to raise_error
      expect{client.open}.not_to raise_error
      
      # 接続待ち(max 10sec)
      10.times do
        break if server_listener.connects != 0 && client_listener.connects != 0
        sleep 1
      end
      expect(server_listener.connects).to eq 1
      expect(client_listener.connects).to eq 1
      client.close
      server.close
    end
  end
  
  context '送信'  do
    it 'サーバ／クライアント間でメッセージ送信できることを確認' do
      server_listener = MockListener.new 'server'
      client_listener = MockListener.new 'client'
      
      server = StreamWebSocketServer.new 'server', '127.0.0.1', 8888, 5
      client = StreamWebSocketClient.new 'client', '127.0.0.1', 8888, 5
      
      server.add_observer StreamObserver::STATUS,  server_listener
      server.add_observer StreamObserver::MESSAGE, server_listener
      client.add_observer StreamObserver::STATUS,  client_listener
      client.add_observer StreamObserver::MESSAGE, client_listener
      
      expect{server.open}.not_to raise_error
      expect{client.open}.not_to raise_error
      # 接続待ち(max 10sec)
      10.times do
        break if server_listener.connects != 0 && client_listener.connects != 0
        sleep 1
      end
      expect{ server.write("server to client") }.not_to raise_error
      expect{ client.write("client to server") }.not_to raise_error
      # 送信待ち(max 10sec)
      10.times do
        break if server_listener.recv_messages == 1 && client_listener.recv_messages == 1
        sleep 1
      end
      expect(server_listener.recv_messages).to eq 1
      expect(server_listener.recv_message).to eq 'client to server'
      expect(client_listener.recv_messages).to eq 1
      expect(client_listener.recv_message).to eq 'server to client'
      
      client.close
      server.close
    end
  end
end

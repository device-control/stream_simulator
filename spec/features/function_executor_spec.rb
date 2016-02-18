# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src'))

require 'yaml'
require 'log'
require 'function_executor'
require 'stream_data/yaml_reader'

require 'pry'

# ダミー実行関数群
$dummy_function_executor_arg = Array.new
def dummy_function_executor00
  # puts "\n### dummy_function_executor00 ###\n"
end

def dummy_function_executor01(arg0)
  # puts "\n### dummy_function_executor01:(#{arg0}) ###\n"
  $dummy_function_executor_arg[0] = arg0
end

def dummy_function_executor02(arg0,arg1)
  # puts "\n### dummy_function_executor02:(#{arg0}, #{arg1}) ###\n"
  $dummy_function_executor_arg[0] = arg0
  $dummy_function_executor_arg[1] = arg1
end

class MockListenerFunctionExecutor
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


describe 'FunctionExecutor' do
  log = Log.instance
  log.disabled
  parameters = {
    type: :TCP_SERVER,
    name: "関数呼び出し用内部TCPサーバ",
    ip: "127.0.0.1",
    port: 9001,
    timeout: 5
  }
  
  before do
  end
  
  context '生成／削除' do
    it '正しく生成／削除されることを確認' do
      expect{ FunctionExecutor.new}.not_to raise_error
      expect{ FunctionExecutor.new parameters}.not_to raise_error
      function_executor = FunctionExecutor.new
      # ２重start
      expect{ function_executor.start }.not_to raise_error
      expect{ function_executor.start }.not_to raise_error
      
      # ２重stop
      expect{ function_executor.stop }.not_to raise_error
      expect{ function_executor.stop }.not_to raise_error
    end
  end

  context '関数実行' do
    it '関数(引数なし)が実行できることを確認' do
      function_executor = nil
      expect{ function_executor = FunctionExecutor.new parameters}.not_to raise_error
      expect{ function_executor.start }.not_to raise_error
      tcp_client = nil
      client_listener = nil
      expect{ tcp_client = StreamTCPClient.new 'tcp_client', '127.0.0.1', 9001, 5}.not_to raise_error
      expect{ client_listener = MockListenerFunctionExecutor.new "MockListenerFunctionExecutor"}.not_to raise_error
      tcp_client.add_observer StreamObserver::STATUS, client_listener
      tcp_client.add_observer StreamObserver::MESSAGE, client_listener
      
      message = {
        "content-type" => "message_fuction",
        "content-version" => 0.1,
        "contents" => {
          "function_name" => "dummy_function_executor00",
          "index" => 1,
          "description" => "dummy_function_executor00()呼び出し。引数ない",
        }
      }
      expect{ tcp_client.open }.not_to raise_error
      expect{ tcp_client.write message.to_yaml.to_s }.not_to raise_error
      5.times do
        sleep 1
        break if client_listener.recv_messages != 0
      end
      expect(client_listener.recv_messages).to eq 1
      # 関数実行結果を確認
      yml = YAML.load(client_listener.recv_message)
      expect(yml["content-type"]).to eq "message_function_result"
      expect(yml["content-version"]).to eq 0.1
      expect(yml["contents"]["function_name"]).to eq "dummy_function_executor00"
      expect(yml["contents"]["index"]).to eq 1
      expect(yml["contents"]["result"]["type"]).to eq "int8"
      expect(yml["contents"]["result"]["value"]).to eq 1
      expect(yml["contents"]["result"]["message"]).to eq "success"
      # 後始末
      expect{ function_executor.stop }.not_to raise_error
    end
    
    it '関数(引数あり:文字列)が実行できることを確認' do
      function_executor = nil
      expect{ function_executor = FunctionExecutor.new }.not_to raise_error
      expect{ function_executor.start }.not_to raise_error
      tcp_client = nil
      client_listener = nil
      expect{ tcp_client = StreamTCPClient.new 'tcp_client', '127.0.0.1', 9001, 5}.not_to raise_error
      expect{ client_listener = MockListenerFunctionExecutor.new "MockListenerFunctionExecutor"}.not_to raise_error
      tcp_client.add_observer StreamObserver::STATUS, client_listener
      tcp_client.add_observer StreamObserver::MESSAGE, client_listener
      
      message = {
        "content-type" => "message_fuction",
        "content-version" => 0.1,
        "contents" => {
          "function_name" => "dummy_function_executor01",
          "index" => 1,
          "description" => "dummy_function_executor01()呼び出し。引数あり",
          "args" => [
            { "type" => "char8", "value" => "ABCDEF" },
          ]
        }
      }
      expect{ tcp_client.open }.not_to raise_error
      expect{ tcp_client.write message.to_yaml.to_s }.not_to raise_error
      5.times do
        sleep 1
        break if client_listener.recv_messages != 0
      end
      expect(client_listener.recv_messages).to eq 1
      # 関数実行結果を確認
      expect($dummy_function_executor_arg[0]).to eq "ABCDEF"
      yml = YAML.load(client_listener.recv_message)
      expect(yml["content-type"]).to eq "message_function_result"
      expect(yml["content-version"]).to eq 0.1
      expect(yml["contents"]["function_name"]).to eq "dummy_function_executor01"
      expect(yml["contents"]["index"]).to eq 1
      expect(yml["contents"]["result"]["type"]).to eq "int8"
      expect(yml["contents"]["result"]["value"]).to eq 1
      expect(yml["contents"]["result"]["message"]).to eq "success"
      # 後始末
      expect{ function_executor.stop }.not_to raise_error
    end
    
    it '関数(引数あり:数値)が実行できることを確認' do
      function_executor = nil
      expect{ function_executor = FunctionExecutor.new parameters}.not_to raise_error
      expect{ function_executor.start }.not_to raise_error
      tcp_client = nil
      client_listener = nil
      expect{ tcp_client = StreamTCPClient.new 'tcp_client', '127.0.0.1', 9001, 5}.not_to raise_error
      expect{ client_listener = MockListenerFunctionExecutor.new "MockListenerFunctionExecutor"}.not_to raise_error
      tcp_client.add_observer StreamObserver::STATUS, client_listener
      tcp_client.add_observer StreamObserver::MESSAGE, client_listener
      
      message = {
        "content-type" => "message_fuction",
        "content-version" => 0.1,
        "contents" => {
          "function_name" => "dummy_function_executor01",
          "index" => 1,
          "description" => "dummy_function_executor01()呼び出し。引数あり",
          "args" => [
            { "type" => "int32", "value" => 0x10 },
          ]
        }
      }
      expect{ tcp_client.open }.not_to raise_error
      expect{ tcp_client.write message.to_yaml.to_s }.not_to raise_error
      5.times do
        sleep 1
        break if client_listener.recv_messages != 0
      end
      expect(client_listener.recv_messages).to eq 1
      # 関数実行結果を確認
      expect($dummy_function_executor_arg[0]).to eq 16
      yml = YAML.load(client_listener.recv_message)
      expect(yml["content-type"]).to eq "message_function_result"
      expect(yml["content-version"]).to eq 0.1
      expect(yml["contents"]["function_name"]).to eq "dummy_function_executor01"
      expect(yml["contents"]["index"]).to eq 1
      expect(yml["contents"]["result"]["type"]).to eq "int8"
      expect(yml["contents"]["result"]["value"]).to eq 1
      expect(yml["contents"]["result"]["message"]).to eq "success"
      # 後始末
      expect{ function_executor.stop }.not_to raise_error
    end
    
    it '関数(引数あり:文字列＋数値)が実行できることを確認' do
      function_executor = nil
      expect{ function_executor = FunctionExecutor.new }.not_to raise_error
      expect{ function_executor.start }.not_to raise_error
      tcp_client = nil
      client_listener = nil
      expect{ tcp_client = StreamTCPClient.new 'tcp_client', '127.0.0.1', 9001, 5}.not_to raise_error
      expect{ client_listener = MockListenerFunctionExecutor.new "MockListenerFunctionExecutor"}.not_to raise_error
      tcp_client.add_observer StreamObserver::STATUS, client_listener
      tcp_client.add_observer StreamObserver::MESSAGE, client_listener
      
      message = {
        "content-type" => "message_fuction",
        "content-version" => 0.1,
        "contents" => {
          "function_name" => "dummy_function_executor02",
          "index" => 1,
          "description" => "dummy_function_executor02()呼び出し。2引数あり",
          "args" => [
            { "type" => "int32", "value" => 0x10 },
            { "type" => "char8", "value" => "ABCDEF12" },
          ]
        }
      }
      expect{ tcp_client.open }.not_to raise_error
      expect{ tcp_client.write message.to_yaml.to_s }.not_to raise_error
      5.times do
        sleep 1
        break if client_listener.recv_messages != 0
      end
      expect(client_listener.recv_messages).to eq 1
      # 関数実行結果を確認
      expect($dummy_function_executor_arg[0]).to eq 16
      expect($dummy_function_executor_arg[1]).to eq "ABCDEF12"
      yml = YAML.load(client_listener.recv_message)
      expect(yml["content-type"]).to eq "message_function_result"
      expect(yml["content-version"]).to eq 0.1
      expect(yml["contents"]["function_name"]).to eq "dummy_function_executor02"
      expect(yml["contents"]["index"]).to eq 1
      expect(yml["contents"]["result"]["type"]).to eq "int8"
      expect(yml["contents"]["result"]["value"]).to eq 1
      expect(yml["contents"]["result"]["message"]).to eq "success"
      # 後始末
      expect{ function_executor.stop }.not_to raise_error
    end
  end
end

# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))

require 'yaml'
require 'stream_manager'
require 'stream_tcp_client'
require 'log'

class FunctionRunner
  attr_reader :connected, :recv_message
  
  def initialize(ip='127.0.0.1',port=50001, timeout=5)
    @parameters = {
      :name => 'FunctionRunner',
      :type => :TCP_CLIENT,
      :ip => ip,
      :port => port,
      :timeout => timeout,
    }
    @stream = StreamManager.create @parameters
    @stream.add_observer StreamObserver::STATUS, self
    @stream.add_observer StreamObserver::MESSAGE, self

    @connected = false
    @recv_message = nil
  end

  # 接続通知
  def stream_connected(stream)
    # puts "接続通知(#{@name}):" + stream.name
    @connected = true
  end

  # 切断通知
  def stream_disconnected(stream)
    # puts "切断通知(#{@name}): " + stream.name
    @connected = false
  end

  # 受信通知
  def stream_message_received(stream,message)
    # puts "受信通知(#{@name}): " + stream.name + " : " + message
    @recv_message = message
  end

  # 開始
  def start
    @stream.open
  end

  # 停止
  def stop
    @stream.close
  end

  # 要求送信(yml)
  def send(send_yml)
    # 接続確認
    start
    5.times do
      break if @connected
      sleep 1
    end
    return false if !@connected # 接続できない場合は失敗
    
    begin
      @recv_message = nil # 結果受信バッファクリア
      @stream.write send_yml.to_s
      5.times do
        break if @recv_message != nil
        sleep 1
      end
      yml = YAML.load @recv_message
      return false if yml["content-type"] != "message_function_result"
      return false if yml["content-version"] != 0.1
      return false if yml["contents"] == nil
      contents = yml["contents"]
      return true if contents["result"]["value"] == 1 # 0:失敗, 1:成功
      puts contents["result"]["message"]
    rescue => e
      puts "Error:FunctionRunnere#send: " + e.message
    end
    return false
  end
  
  # 要求送信(file)
  def send_file(file_path)
    send_yml = nil
    begin
      send_yml = YAML.load_file(file_path)
    rescue => e
      puts "Error:FunctionRunnere#send_file: " + e.message
      return false
    end
    return send(send_yaml)
  end
end


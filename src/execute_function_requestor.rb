# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'log'
require 'stream/stream_manager'
require 'stream/stream_tcp_client'

class ExecuteFunctionRequestor
  attr_reader :connected, :recv_message
  
  def initialize(parameters=nil)
    @parameters = parameters
    if parameters.nil?
      @parameters = {
        :name => 'ExecuteFunctionRequestor',
        :type => :TCP_CLIENT,
        :ip => '127.0.0.1',
        :port => 9001,
        :timeout => 5,
      }
    end
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

  # 要求送信
  def send(function_request)
    # 接続確認
    start
    5.times do
      break if @connected
      sleep 1
    end
    return false if !@connected # 接続できない場合は失敗
    
    begin
      @recv_message = nil # 結果受信バッファクリア
      send_yml = {
        "content-type" => "execute_function_request",
        "content-version" => 0.1,
        "contents" => nil,
      }
      send_yml['contents'] = function_request
      @stream.write send_yml.to_yaml.to_s
      5.times do
        break if @recv_message != nil
        sleep 1
      end
      yml = YAML.load @recv_message
      return false if yml["content-type"] != "execute_function_result"
      return false if yml["content-version"] != 0.1
      return false unless yml.has_key? "contents"
      contents = yml["contents"]
      return true if contents["result"] == :SUCCESS
      puts contents["result"]
    rescue => e
      puts "Error:#{self.class}\##{__method__}: " + e.message
    end
    return false
  end
end


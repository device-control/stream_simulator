# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'stream/stream_manager'
require 'stream_data/message_utils'

require 'log'
require 'stream_log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ExecuteFunctionReceiver
  extend MessageUtils
  attr_reader :client_connected
  attr_reader :stream
  attr_reader :testdata
  attr_reader :receive_message_analyze
  attr_reader :scenario_analyze
  
  # コンストラクタ
  def initialize(parameters=nil)
    @parameters = parameters
    if parameters.nil?
      @parameters = {
        type: :TCP_SERVER,
        name: "関数呼び出し用内部TCPサーバ",
        ip: "127.0.0.1", # default
        port: 9001, # default
        timeout: 5
      }
    end
    @stream = StreamManager.create @parameters
    @client_connected = false
    add_observer
  end
  
  # オブザーバー追加
  def add_observer
    # Streamの状態変化通知
    @stream.add_observer(StreamObserver::STATUS, self)
    # Streamのメッセージ受信通知
    @stream.add_observer(StreamObserver::MESSAGE,self)
  end
  
  # 接続通知
  def stream_connected(stream)
    # puts "通知:FunctionExecutor.stream_coonected: " + stream.name
    @client_connected = true
  end
  
  # 切断通知
  def stream_disconnected(stream)
    # puts "通知:FunctionExecutor.stream_discoonected: " + stream.name
    @client_connected = false
  end

  def get_parameters message
    parameters = nil
    yml = ''
    begin
      yml = YAML.load(message)
      raise "not found content-type" unless yml.has_key? 'content-type'
      raise "unknown format content-type [#{yml['content-type']}]" if yml['content-type'] != 'execute_function_request'
      raise "not found content-version" unless yml.has_key? 'content-version'
      # raise "unknown format content-version [#{yml['content-version']}]" if yml['content-version'] != 0.1
      parameters = yml['contents']
      raise "not found name" unless parameters.has_key?('name')
      raise "not found id" unless parameters.has_key?('id')
      raise "not found function_name" unless parameters.has_key?('function_name')
    rescue => e
      raise "#{self.class}\##{__method__} receive message unknown format.(#{yml.to_s})" + e.message
    end
    return parameters
  end
  
  # 受信通知
  # --- message 内容 ---
  # content-type: execute_function_request
  # content-version: 0.1
  # contents:
  #   name: "Test()呼び出し。入力は適当"
  #   id: 1
  #   function_name: "Test"
  #   args:
  #     - 0
  #     - "arg1"
  #     - 2
  # 
  # --- result 内容 ---
  # content-type: execute_function_result
  # content-version: 0.1
  # contents:
  #   name: "Test()呼び出し。入力は適当"
  #   id: 1
  #   function_name: "Test"
  #   result: :SUCCESS # :SUCCESS=成功, :SUCCESS以外=失敗
  def stream_message_received(stream,message)
    result = {
      "content-type" => "execute_function_result",
      "content-version" => 0.1,
      "contents" => {
        "function_name" => "Unknown function name",
        "id" => 1,
        "result" => :SUCCESS,
      }
    }
    begin
      # (name, id, function_name, args) = get_parameters message
      parameters = get_parameters message
      result['contents']['name'] = parameters['name']
      result['contents']['id'] = parameters['id']
      result['contents']['function_name'] = parameters['function_name']
      # send (name, [arg, ...])
      StreamLog.instance.puts "<execute function> #{parameters.to_s}"
      Log.instance.debug "#{self.class}\##{__method__}: #{parameters.to_s}"
      if parameters.has_key? 'args'
        send parameters['function_name'], *parameters['args']
      else
        send parameters['function_name']
      end
    rescue => e
      StreamLog.instance.puts "<execute function> error: #{parameters.to_s}"
      StreamLog.instance.puts_warning "<execute function> error: #{parameters.to_s}", e.message.split("\n")
      Log.instance.error "#{self.class}\##{__method__}: " + e.message
      result["contents"]["result"] = e.message
    ensure
      write result.to_yaml.to_s
    end
  end

  # 開始
  def start
    @stream.open
  end

  # 停止
  def stop
    @stream.close
  end

  # 送信
  def write(message)
    @stream.write message
  end

end

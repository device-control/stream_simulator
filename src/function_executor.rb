# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'stream/stream_manager'
require 'stream_data/message_utils'

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class FunctionExecutor
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
    name = nil
    args = nil
    begin
      yml = YAML.load(message)
      raise "unknown format(contents)" if !yml.has_key?("contents")
      contents = yml["contents"]
      raise "unknown format(function_name)" if !contents.has_key?("function_name")
      name = contents["function_name"]
      if contents.has_key?("args")
        args = Array.new
        contents["args"].each do |arg|
          args << arg["value"]
        end
      end
    rescue => e
      raise "Error:FunctionExecutor.get_parameters: " + e.message
    end
    return name, args
  end
  
  # 受信通知
  # --- message 内容 ---
  # content-type: message_fuction
  # content-version: 0.1
  # contents:
  #   function_name: "Test"
  #   index: 1
  #   description: "Test()呼び出し。入力は適当"
  #   args:
  #     - type: intX (8,16,32のみ。配列禁止)
  #       value: 0x01 (整数のみHex,Dec)
  #     - type: char[64] (文字列。配列以外禁止)
  #       value: "123456" (文字列)
  # 
  # --- result 内容 ---
  # content-type: message_fuction_result
  # content-version: 0.1
  # contents:
  #   function_name: "Test"
  #   index: 1
  #   result:
  #     type: int8
  #     value: 0x00
  #     message: "例外等の内容"
  def stream_message_received(stream,message)
    result = {
      "content-type" => "message_function_result",
      "content-version" => 0.1,
      "contents" => {
        "function_name" => "Unknown function name",
        "index" => 1,
        "result" => {
          "type" => "int8",
          "value" => 1, # 0:失敗, 1:成功
          "message" => "success", # 理由
        }
      }
    }
    begin
      (function_name,args) = get_parameters message
      result["contents"]["function_name"] = function_name
      # send (name, [arg, ...])
      if args
        send function_name, *args
      else
        send function_name
      end
    rescue => e
      puts "Error:FunctionExecutor#stream_message_received: " + e.message
      result["contents"]["result"]["value"] = 0
      result["contents"]["result"]["message"] = e.message
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

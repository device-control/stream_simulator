# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/stream'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/stream_data'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/stream_runner'))

require 'stream_setting'
require 'stream_manager'

require 'stream_data_creator'

require 'receive_message_analyze'
require 'scenario_analyze'
# require 'function_executor'

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamSimulator
  
  attr_reader :stream
  attr_reader :stream_data
  attr_reader :receive_message_analyze
  attr_reader :scenario_analyze
  
  # コンストラクタ
  def initialize(inparam)
    stream_data_creator = StreamDataCreator.new(inparam[:stream_data_path])
    @stream_data = stream_data_creator.create()
    
    # オブジェクトを生成
    # @receive_message_analyze = ReceiveMessageAnalyze.new @stream_data
    # @scenario_analyze = ScenarioAnalyze.new @stream_data
    stream_parameters = StreamSetting.load inparam[:stream_setting_file_path]
    @stream = StreamManager.create stream_parameters
    # @function_executor = FunctionExecutor.new
    # @function_executor.start
    
    add_observer
  end
  
  # オブザーバー追加
  def add_observer
    # Streamの状態変化通知
    @stream.add_observer(StreamObserver::STATUS, self)
    # @stream.add_observer(StreamObserver::STATUS, @receive_message_analyze)
    # Streamのメッセージ受信通知
    # @stream.add_observer(StreamObserver::MESSAGE, @receive_message_analyze)
    
    # 受信メッセージの解析結果通知
    # @receive_message_analyze.add_observer(@scenario_analyze)
    # シナリオの解析結果通知
    # @scenario_analyze.add_observer(self)
  end
  
  # 接続通知
  def stream_connected(stream)
    puts "通知:StubMain:stream_coonected: " + stream.name
    nil
  end
  
  # 切断通知
  def stream_disconnected(stream)
    puts "通知:StubMain:stream_discoonected: " + stream.name
    nil
  end
  
  # シナリオの解析結果通知
  def analyze_result_received(analyze, result)
    write result
  end
  
  def start
    @stream.open
    return true
  end
  
  def stop
    @stream.close
    return true
  end
  
  def write(message)
    @stream.write message
    return true
  end
  
  def show_message
    @stream_data.message_entities.each do |name, entity|
      message = entity.encode()
      puts message
    end
    return true
  end
  
  def show_message_format
    @stream_data.message_formats.each do |name, format|
      message = format.encode()
      puts message
    end
    return true
  end
  
end

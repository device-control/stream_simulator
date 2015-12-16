# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'stream_tcp_server'
require 'stream_tcp_client'

require 'stream_setting'
require 'stream_manager'

require 'test_data'
require 'receive_message_analyze'
require 'scenario_analyze'
require 'function_executor'

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamSimulator
  
  attr_reader :stream
  attr_reader :testdata
  attr_reader :receive_message_analyze
  attr_reader :scenario_analyze
  
  # コンストラクタ
  def initialize(inparam)
    @testdata = TestData.new inparam[:testdata_path]
    
    # オブジェクトを生成
    @receive_message_analyze = ReceiveMessageAnalyze.new @testdata
    @scenario_analyze = ScenarioAnalyze.new @testdata
    stream_parameters = StreamSetting.load inparam[:stream_setting_file_path]
    @stream = StreamManager.create stream_parameters
    @function_executor = FunctionExecutor.new
    @function_executor.start
    
    add_observer
  end
  
  # オブザーバー追加
  def add_observer
    # Streamの状態変化通知
    @stream.add_observer(StreamObserver::STATUS, self)
    @stream.add_observer(StreamObserver::STATUS, @receive_message_analyze)
    # Streamのメッセージ受信通知
    @stream.add_observer(StreamObserver::MESSAGE, @receive_message_analyze)
    
    # 受信メッセージの解析結果通知
    @receive_message_analyze.add_observer(@scenario_analyze)
    # シナリオの解析結果通知
    @scenario_analyze.add_observer(self)
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
  end
  
  def stop
    @stream.close
  end
  
  def write(message)
    @stream.write message
  end
  
  def show_message
    @testdata.show_message
  end

  def show_message_format
    @testdata.show_message_format
  end

end

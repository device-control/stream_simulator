# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'test_data'
require 'analyze_observer'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ReceiveMessageAnalyze
  include AnalyzeObserver
  
  # コンストラクタ
  def initialize
    super()
    clear()
  end
  
  # データクリア
  def clear
    @message = ""
  end
  
  # メッセージ追加
  def add_message(message)
    @message += message
  end
  
  # 受信通知
  def stream_message_received(stream, message)
    add_message(message)
    analyze()
  end
  
  # 解析処理
  # 受信データからフォーマットを特定する
  # フォーマットが特定できれば、メッセージオブジェクトを生成し、通知する
  def analyze
    # 受信データの解析処理
    loop do
      # フォーマットを検索する
      # 対象のフォーマットがなければ、解析を終了する
      format = TestData.instance.search_message_format(@message)
      break if format.nil?
      
      length = format.length
      message = @message[0, length]
      @message = @message[length, @message.length - length]
      object = TestData.instance.create_message_object(message, format)
      
      # オブザーバーに解析結果を通知
      notify_analyze_result(object)
    end
  end
  
end

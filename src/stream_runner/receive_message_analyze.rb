# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'message_utils'
require 'analyze_observer'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ReceiveMessageAnalyze
  include MessageUtils
  include AnalyzeObserver
  
  # コンストラクタ
  def initialize(testdata)
    super()
    
    @testdata = testdata
    clear()
  end
  
  # データクリア
  def clear
    @message = ""
  end
  
  # メッセージ追加
  def add_message(message)
    @message += binary_to_hex_string(message)
  end
  
  # 接続通知
  def stream_connected(stream)
    clear
  end
  
  # 切断通知
  def stream_disconnected(stream)
    clear
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
      format = @testdata.search_message_format(@message)
      break if format.nil?
      
      message = @message[0, format.message_length]
      @message = @message[format.message_length, @message.length - format.message_length]
      object = @testdata.create_message_object(message, format)
      
      # ログ出力
      Log.instance.info "#{self.class}##{__method__}: command --->"
      object.to_log
      
      # オブザーバーに解析結果を通知
      notify_analyze_result(object)
    end
  end
  
end

# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'stream/stream_observer'
require 'stream_data/message_utils'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageAnalyze
  include MessageUtils
  
  def initialize(stream)
    super stream
    clear
    stream.add_observer(StreamObserver::STATUS, obj)
    stream.add_observer(StreamObserver::MESSAGE,obj)
  end

  # 受信メッセージ削除
  def clear
    @message = ""
  end

  # 接続通知
  def stream_connected(stream)
    clear
    Log.instance.debug "stream_coonected: " + stream.name
  end
  
  # 切断通知
  def stream_disconnected(stream)
    clear
    Log.instance.debug "stream_discoonected: " + stream.name
  end
  
  # 受信通知
  def stream_message_received(stream, message)
    @message += binary_to_hex_string(message)
    analyze()
  end
  
  # 解析処理
  # 受信データからフォーマットを特定する
  # フォーマットが特定できれば、 message_received()メソッドが呼び出される
  def analyze
    # 受信データの解析処理
    loop do
      # # フォーマットを検索する
      # # 対象のフォーマットがなければ、解析を終了する
      # format = @testdata.search_message_format(@message)
      # break if format.nil?
      
      # message = @message[0, format.message_length]
      # @message = @message[format.message_length, @message.length - format.message_length]
      # object = @testdata.create_message_object(message, format)
      
      # # ログ出力
      # Log.instance.info "#{self.class}##{__method__}: command --->"
      # object.to_log
      
      # # 解析結果を通知(callback)
      # message_analyzed(object)
      object = nil # dummy
      message_analyzed(object)
    end
  end
  
end

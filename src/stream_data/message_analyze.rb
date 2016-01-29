# coding: utf-8

require 'stream/stream_observer'
require 'stream_data/message_entity'
require 'stream_data/message_utils'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageAnalyze
  include MessageUtils
  
  def initialize(stream, message_formats)
    raise "stream is nil" if stream.nil?
    raise "message_formats is nil" if message_formats.nil?
    
    @message_formats = message_formats
    clear
    stream.add_observer StreamObserver::STATUS, self
    stream.add_observer StreamObserver::MESSAGE, self
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
    @message += binary_to_hex_string message
    analyze
  end
  
  # 解析処理
  # 受信データからフォーマットを特定する
  # フォーマットが特定できれば、 analyze_completed()メソッドが呼び出される
  def analyze
    # 受信データの解析処理
    loop do
      # Entity生成
      message_entity = MessageEntity.create_from_message @message, @message_formats
      break if message_entity.nil?
      
      # 受信メッセージから解析済みメッセージを削除
      offset = message_entity.member_total_size * 2
      length = @message.length - offset
      @message = @message[offset, length]
      
      # 解析完了を通知(callback)
      analyze_completed message_entity
    end
  end
  
end

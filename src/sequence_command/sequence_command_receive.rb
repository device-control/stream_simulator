# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ受信
class SequenceCommandReceive
  def initialize(arguments, messages, stream, queue, variables)
    raise "not found expected" unless (arguments.has_key? :expected_entity) || (arguments.has_key? :expected_format)

    @arguments = arguments
    @messages = messages
    @stream = stream
    @queue = queue
    @variables = variables
  end
  
  def run
    event = nil
    timeout = @arguments[:timeout]
    # TODO: 期待のmessage_formatが到着するまで繰り返すべきか？
    #       autopilotとの組み合わせ時との動作を検討する必要がある「
    Timeout.timeout(timeout) do # timeout=nil の場合、無限
      event = @queue.pop
      raise "not found name" if event.has_key? :name
      raise "unknown receive event name [#{event[:name]}]" if event[:name] != :message_entity_received
      entity = event[:arguments][0]
      raise "receive message entity is nil" if entity.nil?
      message_name = nil
      message_name = @arguments[:expected_format] if @arguments.has_key? :expected_format
      message_name = @arguments[:expected_entity] if @arguments.has_key? :expected_entity
      raise "not found receve message" if message_name.nil?
      # 期待値と違う
      # TODO: ログだす？
    end
    raise "message receive timeout [#{@arguments[:timeout]}]"
  end
end

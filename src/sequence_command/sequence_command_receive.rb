# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ受信
class SequenceCommandReceive
  
  # 例: sequence yaml
  # - command: receive
  #   arguments:
  #     expected_format: "03.10.01_CommandData03"
  #     timeout: 5 # options
  def initialize(arguments, messages, stream, queue, variables)
    raise "not found :expected_xxx" unless (arguments.has_key? :expected_entity) || (arguments.has_key? :expected_format)
    message_name, type = nil, nil
    message_name, type = arguments[:expected_format], :formats unless arguments.has_key? :expected_format
    message_name, type = arguments[:expected_entity], :entities unless arguments.has_key? :expected_entity
    raise "expected message is nil" if message_name.nil?
    raise "unknown message [#{type}][#{message_name}]" unless messages[type].has_key? message_name
    @expected_message = messages[type][message_name]
    @expected_message_type = type
    
    @arguments = arguments
    @messages = messages
    @stream = stream
    @queue = queue
    @variables = variables
  end
  
  def run
    event = nil
    timeout = @arguments[:timeout] # 指定がなければ nil が入る
    # TODO: 期待のmessage_formatが到着するまで繰り返すべきか？
    #       autopilotとの組み合わせ時との動作を検討する必要がある
    Timeout.timeout(timeout) do # timeout=nil の場合、無限
      event = @queue.pop
      raise "not found :name" unless event.has_key? :name
      raise "not found :arguments" unless event.has_key? :arguments
      raise "unknown receive event name [#{event[:name]}]" unless event[:name] == :message_entity_received
      raise "unknown receive event arguments" unless event[:arguments].class == Array
      raise "receive message entity is nil" if event[:arguments][0].nil?
      actual_message = event[:arguments][0]
      
      # 期待値と違う
      # TODO: ログだす？
      puts "期待メッセージタイプ:[#{@expected_message_type}]"
      puts "期待メッセージ名:[#{@expected_message.name}]"
      puts "結果メッセージ名:[#{actual_message.name}]"
    end
    raise "message receive timeout [#{@arguments[:timeout]}]"
  end
end

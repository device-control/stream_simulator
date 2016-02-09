# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ受信
class SequenceCommandReceive
  
  # 例: sequence yaml
  # - command: :RECEIVE
  #   arguments:
  #     expected_format: "response_format"
  #     timeout: 5 # 秒
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    raise "#{self.class}\##{__method__} parameters[:messages] is nil" if parameters[:messages].nil?
    raise "#{self.class}\##{__method__} parameters[:stream] is nil" if parameters[:stream].nil?
    raise "#{self.class}\##{__method__} parameters[:queues] is nil" if parameters[:queues].nil?
    raise "#{self.class}\##{__method__} parameters[:queues][:sequence] is nil" if parameters[:queues][:sequence].nil?
    SequenceCommandReceive.arguments_permit? parameters[:arguments]

    @arguments = parameters[:arguments]
    messages = parameters[:messages]
    @stream = parameters[:stream]
    @queue = parameters[:queues][:sequence] # シーケンス用キュー使用
    @variables = messages[:variables]
    
    message_name, type = nil, nil
    message_name, type = @arguments[:expected_format], :formats if @arguments.has_key? :expected_format
    message_name, type = @arguments[:expected_entity], :entities if @arguments.has_key? :expected_entity
    raise "#{self.class}\##{__method__} expected message is nil" if message_name.nil?
    raise "#{self.class}\##{__method__} unknown message [#{type}][#{message_name}]" unless messages[type].has_key? message_name
    @expected_message = messages[type][message_name]
    @expected_message_type = type
    
  end

  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found :expected_xxx" unless (arguments.has_key? :expected_entity) || (arguments.has_key? :expected_format)
  end

  
  def run
    StreamLog.instance.puts "expect: type=\"#{@expected_message_type}\", name=\"#{@expected_message.name}\""
    event = nil
    timeout = @arguments[:timeout] # 指定がなければ nil が入る
    # 期待のmessageが到着するかタイムアウトするまで待つ
    # 期待のmessage以外は無視する
    begin
      Timeout.timeout(timeout) do # timeout=nil の場合、無限
        loop do
          event = @queue.pop
          raise "not found :name" unless event.has_key? :name
          raise "not found :arguments" unless event.has_key? :arguments
          raise "unknown receive event name [#{event[:name]}]" unless event[:name] == :message_entity_received
          raise "unknown receive event arguments" unless event[:arguments].class == Array
          raise "receive message entity is nil" if event[:arguments][0].nil?
          actual_message = event[:arguments][0]
          
          StreamLog.instance.puts "command receive: name=\"#{actual_message.name}\""
          StreamLog.instance.puts_message actual_message.get_all_members_with_values @variables
          
          # 期待するメッセージなら終了
          if expected_message? actual_message
            Log.instance.debug "command receive: expected message. name=\"#{actual_message.name}\""
            return
          end
          Log.instance.debug "command receive: not expected message. name=\"#{actual_message.name}\""
        end
      end
    rescue Timeout::Error
      # タイムアウト発生
      raise "message receive timeout [#{@arguments[:timeout]}]"
    end
  end
  
  def expected_message?(actual_message)
    expect = @expected_message.encode @variables
    actual = actual_message.encode @variables
    case @expected_message_type
    when :formats
      # フォーマット名が一致しなければＮＧ
      return false unless actual_message.format.name == @expected_message.name
    when :entities
      # フォーマット名が一致しなければＮＧ
      return false unless actual_message.format.name == @expected_message.format.name
      # データが一致しなければＮＧ
      return false unless expect == actual
    else
      raise "unknown type: #{@expected_message_type}"
    end
    return true
  end
  
end

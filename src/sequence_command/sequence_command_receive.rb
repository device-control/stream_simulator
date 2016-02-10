# coding: utf-8

require 'log'
require 'sequence_command/sequence_command_utils'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ受信
class SequenceCommandReceive
  include SequenceCommandUtils
  
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
    raise "#{self.class}\##{__method__} parameters[:variables] is nil" if parameters[:variables].nil?
    SequenceCommandReceive.arguments_permit? parameters[:arguments]
    
    @arguments = parameters[:arguments]
    messages = parameters[:messages]
    @stream = parameters[:stream]
    @queue = parameters[:queues][:sequence] # シーケンス用キュー使用
    @variables = parameters[:variables]
    
    message_name, type = nil, nil
    message_name, type = @arguments[:expected_format], :formats if @arguments.has_key? :expected_format
    message_name, type = @arguments[:expected_entity], :entities if @arguments.has_key? :expected_entity
    raise "#{self.class}\##{__method__} expected message is nil" if message_name.nil?
    @expected_message_type = message_name == :ANY ? :any : type
    
    unless @expected_message_type == :any
      raise "#{self.class}\##{__method__} unknown message [#{type}][#{message_name}]" unless messages[type].has_key? message_name
      @expected_message = messages[type][message_name]
      
      @override_values = @arguments[:override_values] || Array.new
      @override_values.each do |override_value|
        raise "#{self.class}\##{__method__} unknown member [#{override_value[:name]}]" unless @expected_message.member_list.include? override_value[:name]
      end
      
      @mismatched_action = @arguments[:mismatched_action] || :CONTINUE
    end
    
  end

  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found :expected_xxx" unless (arguments.has_key? :expected_entity) || (arguments.has_key? :expected_format)
    unless arguments[:override_values].nil?
      arguments[:override_values].each.with_index(0) do |override_value, index|
        raise "#{self}.#{__method__} not found :override_values[#{index}][:name]" unless override_value.has_key? :name
        raise "#{self}.#{__method__} not found :override_values[#{index}][:value]" unless override_value.has_key? :value
      end
    end
  end
  
  def run
    StreamLog.instance.puts "expected type=\"#{@expected_message_type}\""
    StreamLog.instance.puts "expected name=\"#{@expected_message.name}\"" unless @expected_message.nil?
    event = nil
    timeout = @arguments[:timeout] # 指定がなければ nil が入る
    # 期待のmessageが到着するかタイムアウトするまで待つ
    # タイムアウトが発生したら、シナリオ終了
    # 期待のmessage以外はミスマッチ時の動作を行う
    begin
      Timeout.timeout(timeout) do # timeout=nil の場合、無限
        loop do
          event = @queue.pop
          raise "#{self.class}\##{__method__} not found :name" unless event.has_key? :name
          raise "#{self.class}\##{__method__} not found :arguments" unless event.has_key? :arguments
          raise "#{self.class}\##{__method__} unknown receive event name [#{event[:name]}]" unless event[:name] == :message_entity_received
          raise "#{self.class}\##{__method__} unknown receive event arguments" unless event[:arguments].class == Array
          raise "#{self.class}\##{__method__} receive message entity is nil" if event[:arguments][0].nil?
          actual_message = event[:arguments][0]
          
          Log.instance.debug "command receive: name=\"#{actual_message.name}\""
          StreamLog.instance.puts "command receive: format name=\"#{actual_message.format.name}\""
          StreamLog.instance.puts_member_list "command receive: member_list=", actual_message.get_all_members_with_values
          
          # :any なら次のコマンドへ進む
          return if @expected_message_type == :any
          
          # expected_message と比較する
          result, details = @expected_message.compare actual_message, get_override_values(@override_values, @variables)
          if result == true
            Log.instance.debug "command receive: expected message. name=\"#{actual_message.name}\""
            return
          end
          
          # 期待するメッセージでない場合
          log_message, log_details = make_mismatched_log details
          Log.instance.debug log_message
          case @mismatched_action
          when :CONTINUE
            # マッチするまで待ち続ける
            StreamLog.instance.puts_warning log_message, log_details
            next
          when :END_OF_SCENARIO
            # シナリオ終了
            raise SequenceCommandError.new log_message, StreamLog.instance.get_position, log_details
          when :NEXT_COMMAND
            # 次のコマンドへ進む
            StreamLog.instance.puts_warning log_message, log_details
            return
          else
            raise "#{self.class}\##{__method__} unknown mismatched action. [#{@mismatched_action}]"
          end
          
        end
      end
    rescue Timeout::Error
      # タイムアウト発生
      log_details = Array.new
      log_details << "timeout=#{@arguments[:timeout]}"
      raise SequenceCommandError.new("receive timeout.", StreamLog.instance.get_position, log_details)
    end
  end
  
  # ミスマッチログのメッセージと詳細を生成する
  def make_mismatched_log(compared_details)
    log_message = ""
    log_details = Array.new
    case compared_details[:reason]
    when :different_format
      # フォーマットが異なる
      log_message = "different format."
      log_details << "expected format name=#{@expected_message.format.name}"
      log_details << "actual format name=#{actual_message.format.name}"
    when :different_values
      # 値が異なる
      log_message = "different values. difference_member_list="
      difference_member_list = compared_details[:difference_member_list] || Array.new
      log_details = difference_member_list.collect {|member |"#{member[:name]}: expected=#{member[:value]} <=> actual=#{member[:compared_value]}" }
    else
      raise "#{self.class}\##{__method__} unknown compared reason: #{compared_details[:reason]}"
    end
    return log_message, log_details
  end
  
end

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
    if message_name == :ANY
      @expected_message_type = :any
    else
      raise "#{self.class}\##{__method__} unknown message [#{type}][#{message_name}]" unless messages[type].has_key? message_name
      @expected_message = messages[type][message_name]
      @expected_message_type = type
    end
    @mismatched_action = @arguments[:mismatched_action] || :CONTINUE
    
  end

  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found :expected_xxx" unless (arguments.has_key? :expected_entity) || (arguments.has_key? :expected_format)
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
          raise "not found :name" unless event.has_key? :name
          raise "not found :arguments" unless event.has_key? :arguments
          raise "unknown receive event name [#{event[:name]}]" unless event[:name] == :message_entity_received
          raise "unknown receive event arguments" unless event[:arguments].class == Array
          raise "receive message entity is nil" if event[:arguments][0].nil?
          actual_message = event[:arguments][0]
          output_receive_entity actual_message
          
          # expected_message と比較する
          compared_result, compared_details = compare_expected_message actual_message
          
          # 期待したメッセージなら、次コマンドへ
          if compared_result == true
            Log.instance.debug "command receive: expected message. name=\"#{actual_message.name}\""
            return
          end
          Log.instance.debug "command receive: not expected message. name=\"#{actual_message.name}\""
          
          # ミスマッチログのメッセージと詳細を生成する
          log_message, log_details = make_mismatched_log compared_details
          
          # ミスマッチ時のアクション
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
            raise "unknown mismatched action. [#{@mismatched_action}]"
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
  
  # expected_message と比較する
  def compare_expected_message(actual_message)
    result = false
    details = Hash.new
    case @expected_message_type
    when :formats, :entities
      result, details = @expected_message.compare actual_message, @variables
    when :any
      result = true
    else
      raise "unknown type: #{@expected_message_type}"
    end
    return result, details
  end
  
  # ミスマッチログのメッセージと詳細を生成する
  def make_mismatched_log(compared_details)
    raise "not found :reason" unless compared_details.has_key? :reason
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
      raise "not found :difference_member_list" unless compared_details.has_key? :difference_member_list
      log_message = "different values. difference_member_list="
      difference_member_list = compared_details[:difference_member_list] || Array.new
      log_details = difference_member_list.collect {|member |"#{member[:name]}: expected=#{member[:value]} <=> actual=#{member[:compared_value]}" }
    else
      raise "unknown compared reason: #{compared_details[:reason]}"
    end
    return log_message, log_details
  end
  
  def output_receive_entity(entity)
    Log.instance.debug "command receive: name=\"#{entity.name}\""
    
    StreamLog.instance.puts "command receive: format name=\"#{entity.format.name}\""
    StreamLog.instance.puts_member_list "command receive: member_list=", entity.get_all_members_with_values(@variables)
  end
  
end

# coding: utf-8

require 'log'
require 'stream_log'
require 'stream_data/message_analyze'
require 'autopilot/autopilot_manager'
require 'sequence_command/sequence_command_creator'
require 'sequence_command/sequence_command_error'
require 'sequence_command/sequence_command_warning'
require 'stream_log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamDataRunner
  include MessageAnalyze
  attr_reader :stream
  attr_reader :sequence_command # 実行中コマンド

  # messages = messages[:formats][name] = format
  #            messages[:entities][name] = entity
  #            messages[:autopilots][name] = autopilot
  #            messages[:variables][name] = variable
  def initialize(stream, messages)
    super stream, messages[:formats]
    # 入力チェック
    raise "stream is nil" if stream.nil?
    raise "not found formats" unless messages.has_key? :formats
    raise "not found entities" unless messages.has_key? :entities
    raise "not found autopilots" unless messages.has_key? :autopilots
    
    @stream = stream
    @messages = messages
    @variables = Hash.new
    @queues = Hash.new
    @queues[:sequence] = Queue.new # sequence用queue
    @queues[:autopilot] = Queue.new # autopilot用queue
    @sequence_command = nil
    # autopilot管理開始
    AutopilotManager.instance.start @queues[:autopilot]
  end

  # sequence内容に従いコマンドを発行する
  #  sequence = sequence[:name]
  #             sequence[:arguments]
  # 例：sequence yaml
  # # 送信
  # - name: :SEND
  #   arguments:
  #     message_entity: "command_entity"
  
  # # 受信
  # - name: :RECEIVE
  #   arguments:
  #     expected_format: "response_format"
  #     timeout: 5 # 秒
  def visit_command(command)
    raise "not found name" unless command.has_key? :name
    raise "not found arguments" unless command.has_key? :arguments
    Log.instance.debug "run command [#{command[:name]}] start"
    StreamLog.instance.push :command, command[:name]
    begin
      @sequence_command = SequenceCommandCreator.create command, @messages, @stream, @queues, @variables
      @sequence_command.run
    rescue SequenceCommandWarning => e
      StreamLog.instance.puts_warning e.message, e.detail
      Log.instance.warn e.message
    rescue SequenceCommandError => e
      StreamLog.instance.puts_error e.message, e.detail
      Log.instance.error e.message
      raise e # シナリオ終了
    rescue => e
      details = Array.new
      StreamLog.instance.puts_error "Scenario ERROR. error_message=\"#{e.message}\"", details
      raise e # シナリオ終了
    end
    
    StreamLog.instance.pop
    Log.instance.debug "run command [#{command[:name]}] end"
  end

  # 外部からsequence_commandを実行する
  def external_command(command)
    StreamLog.instance.push :external_command, command[:name]
    Log.instance.debug "#{self.class}\##{__method__} external_command: #{command.to_s} start"
    begin
      visit_command command
    rescue SequenceCommandError => e
      StreamLog.instance.puts_warning "#{self.class}\##{__method__} can't execute sequence command." + e.message, e.detail
      Log.instance.warn "#{self.class}\##{__method__} can't execute sequence command." + e.message
      raise e
    rescue => e
      StreamLog.instance.puts_warning "#{self.class}\##{__method__} can't execute sequence command." + e.message, [command.to_s]
      Log.instance.warn "#{self.class}\##{__method__} can't execute sequence command." + e.message
      raise e
    ensure
      StreamLog.instance.pop
      Log.instance.debug "#{self.class}\##{__method__} external_command: #{command.to_s} end"
    end
  end
  
  # 受信メッセージを解析してmessage entityが生成されたら呼び出されるメソッド
  def analyze_completed(message_entity)
    Log.instance.debug "#{self.class}\##{__method__} receive: format=\"#{message_entity.format.name}\", message=\"#{message_entity.encode @messages[:variables]}\""
    # StreamLog.instance.puts_member_list "#{self.class}\##{__method__} receive: format=\"#{message_entity.format.name}\", message=\"#{message_entity.encode @messages[:variables]}\", member_list=", message_entity.get_all_members_with_values
    
    event = Hash.new
    event[:name] = :message_entity_received
    event[:arguments] = [ message_entity ]
    # TODO: queues に上限設定が必要(autopilot時にシーケンス側にqueueがたまり続けるため)
    @queues.each do |name,queue|
      queue.push(event)
    end
  end
end


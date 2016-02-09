# coding: utf-8

require 'log'
require 'stream_log'
require 'stream_data/message_analyze'
require 'autopilot/autopilot_manager'
require 'sequence_command/sequence_command_creator'
require 'sequence_command/sequence_command_error'
require 'stream_log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamDataRunner
  include MessageAnalyze
  attr_reader :stream

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
    raise "not found variables" unless messages.has_key? :variables
    
    @stream = stream
    @messages = messages
    @queues = Hash.new
    @queues[:sequence] = Queue.new # sequence用queue
    @queues[:autopilot] = Queue.new # autopilot用queue
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
    Log.instance.debug "run command [#{command[:name]}]"
    StreamLog.instance.push :command, command[:name]
    begin
      command = SequenceCommandCreator.create command, @messages, @stream, @queues
      command.run
    rescue SequenceCommandError => e
      StreamLog.instance.puts_error e.message, e.detail
      raise e # シナリオ終了
    rescue => e
      details = Array.new
      StreamLog.instance.puts_error "Scenario ERROR. error_message=\"#{e.message}\"", details
      raise e # シナリオ終了
    end
    
    StreamLog.instance.pop
  end
  
  # 受信メッセージを解析してmessage entityが生成されたら呼び出されるメソッド
  def analyze_completed(message_entity)
    Log.instance.debug "receive: name=\"#{message_entity.name}\", message=\"#{message_entity.encode @messages[:variables]}\""
    StreamLog.instance.puts "receive: name=\"#{message_entity.name}\", message=\"#{message_entity.encode @messages[:variables]}\""
    event = Hash.new
    event[:name] = :message_entity_received
    event[:arguments] = [ message_entity ]
    @queues.each do |name,queue|
      queue.push(event)
    end
  end
end


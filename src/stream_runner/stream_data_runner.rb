# coding: utf-8

require 'log'
require 'stream_data/message_analyze'
require 'autopilot/autopilot_manager'
require 'sequence_command/sequence_command_creator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamDataRunner
  include MessageAnalyze
  attr_reader :stream

  # messages = messages[:formats][name] = format
  #            messages[:entities][name] = entity
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
  #  sequence = sequence[:command]
  #             sequence[:arguments]
  # 例：sequence yaml
  # - command: send
  #   arguments:
  #     message_entity: "03.10.01_CommandData03"
  # - command: receive
  #   arguments:
  #     expected_format: "03.10.01_CommandData03"
  #     timeout: 5
  def visit_sequence(sequence)
    raise "not found command" unless sequence.has_key? :command
    raise "not found arguments" unless sequence.has_key? :arguments
    command = SequenceCommandCreator.create sequence, @messages, @stream, @queues
    command.run
  end
  
  # 受信メッセージを解析してmessage entityが生成されたら呼び出されるメソッド
  def analyze_completed(message_entity)
    Log.instance.debug "analyze message: [#{message_entity.name}=#{message_entity.encode @messages[:variables]}]"
    event = Hash.new
    event[:name] = :message_entity_received
    event[:arguments] = [ message_entity ]
    @queues.each do |name,queue|
      queue.push(event)
    end
  end
end


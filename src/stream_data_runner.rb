# coding: utf-8

require 'log'
require 'autopilot/autopilot_manager'
require 'sequence_command/sequence_command_creator'
require 'message_analyze'

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

    @variables = Hash.new
    @stream = stream
    @messages = messages
    @queues = Hash.new
    @queues[:sequence] = Queue.new # sequence用queue
    @queues[:autopilot] = Queue.new # autopilot用queue
    # autopilot管理開始
    AutopilotManager.instance.start @queues[:autopilot]
  end

  # sequence = sequence[:command]
  #            sequence[:arguments]
  def visit_sequence(sequence)
    # TODO: yml同様フォーマットの場合は、ここで変換する
    raise "not found command" unless sequence.has_key? :command
    raise "not found arguments" unless sequence.has_key? :arguments
    command = SequenceCommandCreator.create sequence, @messages, @stream, @queues, @variables
    command.run
  end

  # 受信メッセージを解析してmessage entityが生成されたら呼び出されるメソッド
  def analyze_completed(message_entity)
    puts "message_received!!"
    event = Hash.new
    event[:name] = :message_entity_received
    event[:arguments] = [ message_entity ]
    @queues.each do |name,queue|
      queue.push(evnet)
    end
  end
end


# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'
require 'autopilot_runner'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamDataRunner
  include 'message_analyze'
  attr_reader :stream

  # messages = messages[:formats][name] = format
  #            messages[:entities][name] = entity
  def initialize(stream,messages)
    super stream
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


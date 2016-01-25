# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'
require 'autopilot_runner'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamDataRunner
  include 'message_analyze'
  attr_reader :stream

  def initialize(stream)
    super stream
    @variables = Hash.new
    @stream = stream
    @queues = Hash.new
    @queues[:sequence] = Queue.new # sequence用queue
    @queues[:autopilot] = Queue.new # autopilot用queue
  end

  def visit_sequence(sequence,messages)
    # sequence = :command
    #            :arguments
    # messages = :formats
    #            :entites
    command = SequenceCommandCreator.create sequence, messages, @stream, @queues, @variables
    command.run
  end

  # 解析してmessage_entityが生成されたら呼び出されるメソッド
  def message_received(obj)
    puts "message_received!!"
    event = Hash.new
    event[:name] = :message_receive
    event[:arguments] = [ obj ]
    @queues.each do |name,queue|
      queue.push(evnet)
    end
  end
end


# coding: utf-8

require 'singleton'
require 'timeout'
require 'autopilot/autopilot_auto_response'
require 'autopilot/autopilot_interval_send'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロットマネージャ
class AutopilotManager
  include Singleton

  def initialize
    @autopilots = Hash.new
    @running = false
  end

  # 開始
  def start(queue)
    return false if @running # 失敗(開始済み)
    @queue = queue
    @thread = Thread.new(&method(:message_entity_received))
    @running = true
    return true # 成功
  end

  # 終了
  def stop
    @thread.kill
    @thread.join
    @thread = nil
    @running = false
  end

  # autopilot 登録
  def create(arguments, messages, stream, variables)
    raise "not found :autopilot" unless messages.has_key? :autopilot
    raise "not found :name" unless arguments.has_key? :name
    raise "unknown autopilot name [#{arguments[:name]}]" unless messages[:autopilot].has_key? arguments[:name]
    name = arguments[:name]
    autopilot = messages[:autopilot][name]
    if autopilot.type == :AUTO_RESPONSE
      @autopilots[name] = AutopilotAutoResponse.new(autopilot.arguments,messages,stream, variables)
    elsif autopilot.type == :INTERVAL_SEND
      @autopilots[name] = AutopilotIntervalSend.new(autopilot.arguments,messages,stream, variables)
    else
      raise "unknown type [#{autopilot.type}]"
    end
    @autopilots[name].start
  end

  # autopilot 削除
  def delete(arguments)
    raise "not found :name" unless arguments.has_key? :name
    @autopilots.delete(arguments[:name])
  end

  # message entitiy 受信待ち
  private
  def message_entity_received
    loop do
      begin
        break if @running == false
        event = nil
        Timeout.timeout(1) do
          event = @queue.pop
        end
        next if event.nil?
        raise "not found :name" unless event.has_key? :name
        raise "not found :arguments" unless event.has_key? :arguments
        raise "unknown event name [#{event[:name]}]" unless event[:name] == :message_entity_received
        @autopilots.each do |name,autopilot|
          # autopilots に message entity 通知
          autopilot.message_entity_notify event[:arguments][0]
        end
      rescue Timeout::Error
        next
      end
    end
  end
  
end


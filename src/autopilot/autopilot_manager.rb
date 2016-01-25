# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'singleton'
require 'timeout'
require 'autopilot_auto_response'
require 'autopilot_intaval_send'
require '../log'

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
    return true # 成功
  end

  # message entitiy 受信待ち
  def message_entity_received
    @running = true
    loop do
      begin
        break if @running == false
        event = nil
        Timeout.timeout(1) do
          event = @queue.pop
        end
        next if event.nil?
        raise "not found name" unless event.has_key? :name
        raise "not found arguments" unless event.has_key? :arguments
        raise "unknown event name [#{event[:name]}]" if event[:name] != :message_entity_received
        @autopilots.each do |name,autopilot|
          # autopilots に message entity 通知
          autopilot.message_entity_notify event[:arguments][0]
        end
      rescue Timeout::Error
        next
      end
    end
  end

  # 終了
  def stop
    @thread.kill
    @thread.join
    @thread = nil
    @running = false
  end

  # autopilot 登録
  # arguments
  #  :name = autopilot name
  #
  def create(arguments, messages, stream)
    raise "not found autopilot" unless messages.has_key? :autopilot
    raise "not found name" unless arguments.has_key? :name
    name = arguments[:name]
    body = messages[:autopilot][name]
    contents = body["contents"]
    if contents["type"] == "autopilot_response"
      @autopilots[name] = AutopilotAutoResponse.new(contents[:arguments],message,stream)
    elsif contents["type"] = "interval_send"
      @autopilots[name] = AutopilotIntervalSend.new(contents[:arguments],message,stream)
    else
      raise "unknown type [#{contents["type"]}]"
    end
    @autopilots[name].start
  end

  # autopilot 削除
  def delete(arguments)
    raise "not found name" unless arguments.has_key? :name
    @autopilots.delete(arguments[:name])
  end
  
end


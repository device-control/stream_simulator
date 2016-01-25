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
    @queue = queue
    @thread = Thread.new(&method(:message_received))
  end

  # message entitiy 受信待ち
  def message_received
    @running = true
    loop do
      begin
        break if @running == false
        event = nil
        Timeout.timeout(1) do
          event = @queue.pop
        end
        next if event.nil?
        @autopilots.each do |name,autopilot|
          # autopilots に message entity 通知
          autopilot.message_notify event[:arguments][0]
        end
      rescue Timeout::Error
        next
      end
    end
  end

  # 終了
  def stop
    @running = false
  end

  # autopilot 登録
  # arguments
  #  :name = autopilot name
  #
  def add(arguments, messages, stream)
    raise "not found autopilot" unless messages.has_key? :autopilot
    raise "not found name" unless arguments.has_key? :name
    name = arguments[:name]
    body = messages[:autopilot][name]
    contents = body["contents"]
    if contents["type"] == "autopilot_response"
      @autopilots[name] = AutopilotAutoResponse.new(contents,message,stream)
    elsif contents["type"] = "interval_send"
      @autopilots[name] = AutopilotIntervalSend.new(contents,message,stream)
    else
      raise "unknown type [#{contents["type"]}]"
    end
  end

  # autopilot 削除
  def delete(arguments)
    raise "not found name" unless arguments.has_key? :name
    @autopilots.delete(arguments[:name])
  end
  
end

# coding: utf-8

require 'log'
require 'stream/stream_observer'
require 'sequence_command/sequence_command_utils'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# ストリーム開始
class SequenceCommandOpen
  extend SequenceCommandUtils
  
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    raise "#{self.class}\##{__method__} parameters[:stream] is nil" if parameters[:stream].nil?
    SequenceCommandOpen.arguments_permit? parameters[:arguments]
    @stream = parameters[:stream]
    @timeout = nil
    if !parameters[:arguments].nil? # argumentsがあれば、timeoutが指定されている場合がある
      @timeout = parameters[:arguments][:timeout]
    end
    @connected = false
    @stream.add_observer(StreamObserver::STATUS, self)
  end
  
  def self.arguments_permit?(arguments)
    return if arguments.nil?
    # 必須パラメータなし
    # オプションパラメータあり
    if arguments.has_key? :timeout
      raise "#{self}.#{__method__} arguments[:timeout] not integer [#{arguments[:timeout]}]" if !integer_string? arguments[:timeout]
    end
  end
  
  def run
    StreamLog.instance.puts "command open: name=\"#{@stream.name}\", ip=\"#{@stream.ip}\", port=\"#{@stream.port}\""
    begin
      @stream.open # TODO: TCPClientの場合、タイムアウト値と関係なく接続できない場合、そく"open error."となってしまう。
      # 接続待ち
      Timeout.timeout(@timeout) do # timeout=nil の場合、無限
        loop do
          break if @connected
          sleep 1
        end
        @stream.delete_observer(StreamObserver::STATUS, self)
      end
    rescue Timeout::Error
      # タイムアウト発生
      log_details = Array.new
      log_details << "timeout=#{@timeout}}"
      raise SequenceCommandError.new("open timeout.", StreamLog.instance.get_position, log_details)
    rescue => e
      raise SequenceCommandError.new("open error.", StreamLog.instance.get_position, [e.message])
    end
  end
  
  # 接続通知
  def stream_connected(stream)
    @connected = true
  end
  
  # 切断通知
  def stream_disconnected(stream)
    # 何もしない
  end
  
end

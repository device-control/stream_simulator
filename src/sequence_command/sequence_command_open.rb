# coding: utf-8

require 'log'
require 'stream/stream_observer'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# ストリーム開始
class SequenceCommandOpen
  def initialize(stream)
    @stream = stream
    @connected = false
    @stream.add_observer(StreamObserver::STATUS, self)
  end
  
  def run
    StreamLog.instance.puts "command open: name=\"#{@stream.name}\", ip=\"#{@stream.ip}\", port=\"#{@stream.port}\""
    @stream.open
    # 接続待ち
    loop do
      break if @connected
      sleep 1
    end
    @stream.delete_observer(StreamObserver::STATUS, self)
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

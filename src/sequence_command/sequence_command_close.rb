# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require '../log'
require '../stream/stream_tcp_server'
require '../stream/stream_tcp_client'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# ストリーム終了
class SequenceCommandClose
  def initialize(stream)
    @stream = stream
  end
  
  def run
    @stream.close
  end

end
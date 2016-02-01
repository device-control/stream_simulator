# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# ストリーム終了
class SequenceCommandClose
  def initialize(stream)
    @stream = stream
  end
  
  def run
    Log.instance.debug "run command [Close]"
    @stream.close
  end

end

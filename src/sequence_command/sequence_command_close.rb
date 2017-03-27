# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# ストリーム終了
class SequenceCommandClose
  
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    raise "#{self.class}\##{__method__} parameters[:stream] is nil" if parameters[:stream].nil?
    SequenceCommandClose.arguments_permit? parameters[:arguments]
    @stream = parameters[:stream]
  end
  
  def self.arguments_permit?(arguments)
    # 入力パラメータなし
  end
  
  def run
    # StreamLog.instance.puts "command close: name=\"#{@stream.name}\", ip=\"#{@stream.ip}\", port=\"#{@stream.port}\""
    StreamLog.instance.puts "command close: name=\"#{@stream.name}\""
    @stream.close
  end

end

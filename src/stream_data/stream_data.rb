# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamData
  
  attr_accessor :message_formats
  attr_accessor :message_entities
  attr_accessor :scenarios
  attr_accessor :sequences
  attr_accessor :autopilots
  
  # コンストラクタ
  def initialize()
  end
  
  def accept(visitor)
    visitor.visit(@message_formats, @message_entities, @scenarios, @sequences, @autopilots)
  end
  
end

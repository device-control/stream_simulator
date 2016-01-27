# coding: utf-8

require 'log'
require 'stream_data/stream_data_creator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamData
  extend StreamDataCreator
  
  attr_accessor :message_formats
  attr_accessor :message_entities
  attr_accessor :scenarios
  attr_accessor :sequences
  attr_accessor :autopilots
  
  # コンストラクタ
  def initialize()
  end
  
  def accept(visitor)
    @scenarios.each do |name, scenario|
      scenario.accept visitor
    end
  end
  
end

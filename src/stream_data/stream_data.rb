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
  attr_accessor :stream_settings
  attr_accessor :variables
  
  # コンストラクタ
  def initialize()
  end
  
  def accept(visitor, scenario_name)
    raise "visitor is nil" if visitor.nil?
    raise "scenario_name is nil" if scenario_name.nil?
    
    # シナリオが存在しない場合、ログに出力して終了
    unless @scenarios.has_key? scenario_name
      Log.instance.debug "scenario not found: name=[#{scenario_name}]"
      return
    end
    
    @scenarios[scenario_name].accept visitor
  end
  
end

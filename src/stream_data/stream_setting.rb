# coding: utf-8

require 'log'
require 'stream_data/stream_setting_creator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamSetting
  extend StreamSettingCreator
  
  attr_reader :name
  attr_reader :file
  attr_reader :parameters
  
  # コンストラクタ
  def initialize(name, file, parameters)
    raise "name is nil" if name.nil?
    raise "file is nil" if file.nil?
    raise "parameters is nil" if parameters.nil?
    
    @name = name
    @file = file
    @parameters = parameters
  end
  
end

# coding: utf-8

require 'log'
require 'stream_data/autopilot_creator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class Autopilot
  extend AutopilotCreator
  
  attr_reader :name
  attr_reader :file
  attr_reader :type
  attr_reader :arguments
  
  # コンストラクタ
  def initialize(name, file, type, arguments)
    @name = name
    @file = file
    @type = type
    @arguments = arguments
  end
  
end

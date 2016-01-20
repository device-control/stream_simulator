# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class Autopilot
  
  attr_reader :name
  attr_reader :file
  attr_reader :autopilot
  
  # コンストラクタ
  def initialize(name, file, autopilot)
    @name = name
    @file = file
    @autopilot = autopilot
  end
  
end

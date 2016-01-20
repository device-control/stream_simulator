# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class Scenario
  
  attr_reader :name
  attr_reader :file
  attr_reader :sequence
  
  # コンストラクタ
  def initialize(name, file, sequence)
    @name = name
    @file = file
    @sequence = sequence
  end
  
end

# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class Scenario
  
  attr_reader :name
  attr_reader :file
  attr_reader :sequences
  
  # コンストラクタ
  def initialize(name, file, sequences)
    @name = name
    @file = file
    @sequences = sequences
  end
  
end

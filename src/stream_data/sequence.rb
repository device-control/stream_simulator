# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class Sequence
  
  attr_reader :name
  attr_reader :file
  attr_reader :commands
  
  # コンストラクタ
  def initialize(name, file, commands)
    @name = name
    @file = file
    @commands = commands
  end
  
end

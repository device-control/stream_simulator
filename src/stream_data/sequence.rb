# coding: utf-8

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
  
  def accept(visitor)
    @commands.each do |command|
      sequence = Hash.new
      sequence[:command] = command['command']
      sequence[:arguments] = command['arguments']
      
      visitor.visit_sequence sequence
    end
  end
  
end

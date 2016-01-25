# coding: utf-8

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
  
  def accept(visitor)
    @sequences.each do |name, sequence|
      sequence.accept(visitor)
    end
  end
  
end

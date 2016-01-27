# coding: utf-8

require 'log'
require 'stream_data/scenario_creator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class Scenario
  extend ScenarioCreator
  
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
    @sequences.each do |sequence|
      sequence.accept visitor
    end
  end
  
end

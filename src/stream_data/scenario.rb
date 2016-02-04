# coding: utf-8

require 'log'
require 'stream_log'
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
    raise "name is nil" if name.nil?
    raise "file is nil" if file.nil?
    raise "sequences is nil" if sequences.nil?
    
    @name = name
    @file = file
    @sequences = sequences
  end
  
  def accept(visitor)
    raise "visitor is nil" if visitor.nil?
    StreamLog.instance.push :scenario, @name
    
    @sequences.each do |sequence|
      sequence.accept visitor
    end

    StreamLog.instance.pop
  end
  
end

# coding: utf-8

require 'log'
require 'stream_data/sequence_creator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class Sequence
  extend SequenceCreator
  
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
      visitor.visit_sequence command
    end
  end
  
end

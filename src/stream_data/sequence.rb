# coding: utf-8

require 'log'
require 'stream_log'
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
    raise "name is nil" if name.nil?
    raise "file is nil" if file.nil?
    raise "commands is nil" if commands.nil?
    
    @name = name
    @file = file
    @commands = commands
  end
  
  def accept(visitor)
    raise "visitor is nil" if visitor.nil?
    StreamLog.instance.push :sequence, @name
    
    @commands.each do |command|
      visitor.visit_command command
    end
    
    StreamLog.instance.pop
  end
  
end

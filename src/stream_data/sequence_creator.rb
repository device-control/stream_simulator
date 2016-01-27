# coding: utf-8

require 'log'
require 'stream_data/sequence'
require 'stream_data/extend_hash'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module SequenceCreator
  
  # Sequence 生成処理
  def create(name, yaml)
    raise "yaml is nil" if yaml.nil?
    raise "not found file" unless yaml.has_key? :file
    raise "not found body" unless yaml.has_key? :body
    raise "not found contents" unless yaml[:body].has_key? 'contents'
    raise "not found commands" unless yaml[:body]['contents'].has_key? 'commands'
    raise "commands not Array" unless yaml[:body]['contents']['commands'].instance_of? Array
    
    # commands のシンボル変換
    commands = Array.new
    yaml[:body]['contents']['commands'].each do |command|
      target_command? command
      # command のシンボル変換
      command.extend ExtendHash
      command = command.symbolize_keys
      unless command[:arguments].nil?
        command[:arguments].extend ExtendHash
        command[:arguments] = command[:arguments].symbolize_keys
      end
      commands << command
    end
    
    return Sequence.new name, yaml[:file], commands
  end
  
  def target_command?(command)
    raise "command is nil" if command.nil?
    raise "not found command" unless command.has_key? 'command'
    raise "not found arguments" unless command.has_key? 'arguments'
    
    arguments = command['arguments']
    case command['command']
    when :OPEN
      # arguments なし
    when :SEND
      raise "not found message_entity" unless arguments.has_key? 'message_entity'
    when :RECEIVE
      raise "not found expected_xxx" unless (arguments.has_key? 'expected_entity') || (arguments.has_key? 'expected_format')
    when :WAIT
      raise "not found time" unless arguments.has_key? 'time'
      raise "undefined time [#{arguments['time']}]" if (arguments['time'].instance_of? Symbol) && (arguments['time'] != :WAIT_FOR_EVER)
    when :SET_VARIABLE
      raise "not found name" unless arguments.has_key? 'name'
      raise "not found command" unless arguments.has_key? 'command'
    when :AUTOPILOT_START
      raise "not found name" unless arguments.has_key? 'name'
    when :AUTOPILOT_END
      raise "not found name" unless arguments.has_key? 'name'
    when :CLOSE
      # arguments なし
    else
      raise "undefined command [#{command['command']}]"
    end
  end
  
end

# coding: utf-8

require 'log'
require 'sequence_command/sequence_command_open'
require 'sequence_command/sequence_command_close'
require 'sequence_command/sequence_command_send'
require 'sequence_command/sequence_command_receive'
require 'sequence_command/sequence_command_wait'
require 'sequence_command/sequence_command_set_variable'
require 'sequence_command/sequence_command_autopilot_start'
require 'sequence_command/sequence_command_autopilot_end'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# シーケンスコマンド生成
class SequenceCommandCreator
  
  SEQUENCE_COMMAND_CLASS_LIST = {
    OPEN: SequenceCommandOpen,
    SEND: SequenceCommandSend,
    RECEIVE: SequenceCommandReceive,
    WAIT: SequenceCommandWait,
    SET_VARIABLE: SequenceCommandSetVariable,
    AUTOPILOT_START: SequenceCommandAutopilotStart,
    AUTOPILOT_END: SequenceCommandAutopilotEnd,
    CLOSE: SequenceCommandClose,
  }
  
  def self.create(command, messages, stream, queues)
    raise "#{self}.#{__method__} command is nil" if command.nil?
    raise "#{self}.#{__method__} not found :name" unless command.has_key? :name
    raise "#{self}.#{__method__} not found :arguments" unless command.has_key? :arguments
    arguments = command[:arguments]

    parameters = {
      arguments: arguments,
      messages: messages,
      stream: stream,
      queues: queues,
    }
    
    raise "unknown command [#{command[:name]}]" unless SEQUENCE_COMMAND_CLASS_LIST.has_key? command[:name]
    return SEQUENCE_COMMAND_CLASS_LIST[command[:name]].new parameters
  end

  def self.command_permit?(command)
    raise "#{self}.#{__method__} command is nil" if command.nil?
    raise "#{self}.#{__method__} not found name" unless command.has_key? :name
    raise "#{self}.#{__method__} not found arguments" unless command.has_key? :arguments
    raise "#{self}.#{__method__} unknon command [#{command[:name]}]" unless SEQUENCE_COMMAND_CLASS_LIST.has_key? command[:name]
    SEQUENCE_COMMAND_CLASS_LIST[command[:name]].arguments_permit? command[:arguments]
  end
  
end


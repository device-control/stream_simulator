# coding: utf-8

require 'log'
require 'autopilot/autopilot_manager'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'


# オートパイロット開始
class SequenceCommandAutopilotStart
  def initialize(arguments, messages, stream, variables)
    @arguments = arguments
    @messages = messages
    @stream = stream
    @variables = variables
  end
  
  def run
    AutopilotManager.instance.create @arguments, @messages, @stream, @variables
  end
  
end


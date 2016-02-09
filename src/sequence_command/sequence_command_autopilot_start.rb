# coding: utf-8

require 'log'
require 'autopilot/autopilot_manager'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット開始
class SequenceCommandAutopilotStart
  
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    raise "#{self.class}\##{__method__} parameters[:messages] is nil" if parameters[:messages].nil?
    raise "#{self.class}\##{__method__} parameters[:stream] is nil" if parameters[:stream].nil?
    SequenceCommandAutopilotStart.arguments_permit? parameters[:arguments]
    @arguments = parameters[:arguments]
    @messages = parameters[:messages]
    @stream = parameters[:stream]
  end
  
  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found name" unless arguments.has_key? :name
  end
  
  def run
    AutopilotManager.instance.create @arguments, @messages, @stream
  end
  
end


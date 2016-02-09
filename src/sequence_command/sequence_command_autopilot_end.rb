# coding: utf-8

require 'log'
require 'autopilot/autopilot_manager'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット終了
class SequenceCommandAutopilotEnd
  
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    SequenceCommandAutopilotEnd.arguments_permit? parameters[:arguments]
    @arguments = parameters[:arguments]
  end
  
  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found name" unless arguments.has_key? :name
  end
  
  def run
    AutopilotManager.instance.delete @arguments
  end
  
end


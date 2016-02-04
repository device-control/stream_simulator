# coding: utf-8

require 'log'
require 'autopilot/autopilot_manager'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット終了
class SequenceCommandAutopilotEnd
  def initialize(arguments)
    @arguments = arguments
  end
  
  def run
    AutopilotManager.instance.delete @arguments
  end
  
end


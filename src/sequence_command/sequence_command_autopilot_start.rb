# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require '../log'
require '../autopilot/autopilot_manager'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'


# オートパイロット開始
class SequenceCommandAutopilotStart
  def initialize(arguments, messages, stream)
    @arguments = arguments
    @messages = messages
    @stream = stream
  end
  
  def run
    AutopilotManager.instance.add @arguments, @messages, @stream
  end
  
end

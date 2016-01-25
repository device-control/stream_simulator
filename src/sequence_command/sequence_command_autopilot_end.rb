# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require '../log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット終了
class SequenceCommandAutopilotEnd
  def initialize(arguments, messages, stream)
    @arguments = arguments
    @messages = messages
    @stream = stream
  end
  
  def run
    AutopilotManager.instance.delete @arguments
  end
  
end


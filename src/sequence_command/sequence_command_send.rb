# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require '../log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ送信
class SequenceCommandSend
  def initialize(arguments, messages, stream)
    @arguments = arguments
    @messages = messages
    @stream = stream
  end
  
  def run
    entity = messages[:formats][arguments[:message_data]]
    if entity.nil?
      raise "SequenceCommandSend#run: unknown message_entity [#{arguments[:message_data]}]"
    end
    stream.write entity.encode
  end
end

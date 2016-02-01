# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ送信
class SequenceCommandSend
  # 例: sequence yaml
  # - command: :SEND
  #   arguments:
  #     message_entity: "command_entity"
  def initialize(arguments, messages, stream)
    raise "not found :message_entity" unless arguments.has_key? :message_entity
    raise "unknown message_entity [#{arguments[:message_entity]}]" unless messages[:entities].has_key? arguments[:message_entity]
    @send_entity = messages[:entities][arguments[:message_entity]]
    
    @arguments = arguments
    @messages = messages
    @stream = stream
    @variables = messages[:variables]
  end
  
  def run
    Log.instance.debug "run command [SEND]"
    @stream.write @send_entity.encode @variables, :binary
  end
end

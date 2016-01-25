# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ送信
class SequenceCommandSend
  def initialize(arguments, messages, stream, variables)
    raise "not found message_entity" unless arguments.has_key? :message_entity
    
    @arguments = arguments
    @messages = messages
    @stream = stream
    @variables = variables
  end
  
  def run
    raise "unknown message_entity [#{arguments[:message_entity]}]" if messages[:entities].has_key? arguments[:message_entity]
    entity = messages[:entities][arguments[:message_entity]]
    # TODO: グローバル変数を置換する場合、@variables指定が必要
    #       ex) @stream.write entity.encode, @variables
    @stream.write entity.encode
  end
end

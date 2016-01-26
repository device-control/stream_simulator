# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ送信
class SequenceCommandSend
  # 例: sequence yaml
  # - command: send
  #   arguments:
  #     message_entity: "03.10.01_CommandData03"
  def initialize(arguments, messages, stream, variables)
    raise "not found :message_entity" unless arguments.has_key? :message_entity
    raise "unknown message_entity [#{arguments[:message_entity]}]" unless messages[:entities].has_key? arguments[:message_entity]
    @send_entity = messages[:entities][arguments[:message_entity]]

    @arguments = arguments
    @messages = messages
    @stream = stream
    @variables = variables
  end
  
  def run
    # TODO: グローバル変数を置換する場合、@variables指定が必要
    #       ex) @stream.write @send_entity.encode, @variables
    @stream.write @send_entity.encode
  end
end

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
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    raise "#{self.class}\##{__method__} parameters[:messages] is nil" if parameters[:messages].nil?
    raise "#{self.class}\##{__method__} parameters[:messages][:entities] is nil" if parameters[:messages][:entities].nil?
    raise "#{self.class}\##{__method__} parameters[:messages][:variables] is nil" if parameters[:messages][:variables].nil?
    raise "#{self.class}\##{__method__} parameters[:stream] is nil" if parameters[:stream].nil?
    SequenceCommandSend.arguments_permit? parameters[:arguments]
    arguments = parameters[:arguments]
    messages = parameters[:messages]
    @stream = parameters[:stream]
    @variables = messages[:variables]

    raise "#{self.class}\##{__method__} unknown message_entity [#{arguments[:message_entity]}]" unless messages[:entities].has_key? arguments[:message_entity]
    @send_entity = messages[:entities][arguments[:message_entity]]
    
  end
  
  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found :message_entity" unless arguments.has_key? :message_entity
  end
  
  def run
    output_send_entity @send_entity
    @stream.write @send_entity.encode @variables, :binary
  end
  
  def output_send_entity(entity)
    Log.instance.debug "command send: name=\"#{entity.name}\", message=\"#{entity.encode @variables}\""
    
    StreamLog.instance.puts "command send: name=\"#{entity.name}\", message=\"#{entity.encode @variables}\""
    StreamLog.instance.puts_member_list "command send: member_list=", entity.get_all_members_with_values(@variables)
  end
  
end

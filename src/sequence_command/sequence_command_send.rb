# coding: utf-8

require 'log'
require 'sequence_command/sequence_command_utils'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# メッセージ送信
class SequenceCommandSend
  include SequenceCommandUtils
  
  # 例: sequence yaml
  # - command: :SEND
  #   arguments:
  #     message_entity: "command_entity"
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    raise "#{self.class}\##{__method__} parameters[:messages] is nil" if parameters[:messages].nil?
    raise "#{self.class}\##{__method__} parameters[:messages][:entities] is nil" if parameters[:messages][:entities].nil?
    raise "#{self.class}\##{__method__} parameters[:variables] is nil" if parameters[:variables].nil?
    raise "#{self.class}\##{__method__} parameters[:stream] is nil" if parameters[:stream].nil?
    SequenceCommandSend.arguments_permit? parameters[:arguments]
    
    arguments = parameters[:arguments]
    messages = parameters[:messages]
    @stream = parameters[:stream]
    @variables = parameters[:variables]
    
    raise "#{self.class}\##{__method__} unknown message_entity [#{arguments[:message_entity]}]" unless messages[:entities].has_key? arguments[:message_entity]
    @send_entity = messages[:entities][arguments[:message_entity]]
    
    @override_values = arguments[:override_values] || Array.new
    @override_values.each do |override_value|
      raise "#{self.class}\##{__method__} unknown member [#{override_value[:name]}]" unless @send_entity.member_list.include? override_value[:name]
    end
    
  end
  
  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found :message_entity" unless arguments.has_key? :message_entity
    unless arguments[:override_values].nil?
      arguments[:override_values].each.with_index(0) do |override_value, index|
        raise "#{self}.#{__method__} not found :override_values[#{index}][:name]" unless override_value.has_key? :name
        raise "#{self}.#{__method__} not found :override_values[#{index}][:value]" unless override_value.has_key? :value
      end
    end
  end
  
  def run
    override_values = get_override_values(@override_values, @variables)
    Log.instance.debug "command send: name=\"#{@send_entity.name}\", message=\"#{@send_entity.encode override_values}\""
    StreamLog.instance.puts "command send: name=\"#{@send_entity.name}\", message=\"#{@send_entity.encode override_values}\""
    StreamLog.instance.puts_member_list "command send: member_list=", @send_entity.get_all_members_with_values(override_values)
    @stream.write @send_entity.encode override_values, :binary
  end
  
end

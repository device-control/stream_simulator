# coding: utf-8

require 'log'
require 'stream_data/message_entity'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageEntityCreator
  
  # MessageEntity を生成する
  def create(name, yaml, message_formats)
    begin
      raise "name is nil" if name.nil?
      raise "yaml is nil" if yaml.nil?
      raise "message_formats is nil" if message_formats.nil?
      raise "not found file" unless yaml.has_key? :file
      raise "not found body" unless yaml.has_key? :body
      raise "not found contents" unless yaml[:body].has_key? 'contents'
      
      raise "not found using_format" unless yaml[:body]['contents'].has_key? 'using_format'
      using_format = yaml[:body]['contents']['using_format']
      
      raise "not found format. [#{using_format}]" unless message_formats.has_key? using_format
      format = message_formats[using_format]
      
      values = yaml[:body]['contents']['values'] || Hash.new
      values.each do |key, value|
        raise "not found [#{key}] in member_list" unless format.member_list.include? key
        member_data = format.get_member key
        raise "invalid value: key=[#{key}] value=[#{value}]" unless member_data.valid? value
      end
      
      return MessageEntity.new name, yaml[:file], format, values
    rescue => e
      raise "#{e.message}\n file=[#{yaml[:file]}]"
    end
  end
  
  # メッセージから MessageEntity を生成する
  def create_from_message(message, message_formats)
    raise "message is nil" if message.nil?
    raise "message_formats is nil" if message_formats.nil?
    # フォーマットを特定する
    target_format = nil
    values = nil
    message_formats.each do |name, message_format|
      values = message_format.decode message
      next if values.nil?
      if message_format.target? values
        target_format = message_format
        break
      end
    end
    return nil if target_format.nil?
    return MessageEntity.new target_format.name, '', target_format, values
  end
  
end

# coding: utf-8

require 'log'
require 'stream_data/message_entity'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageEntityCreator
  
  # MessageEntity を生成する
  def create(name, yaml, message_formats)
    raise "yaml is nil" if yaml.nil?
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
    end
    
    return MessageEntity.new name, yaml[:file], format, values
  end
  
end

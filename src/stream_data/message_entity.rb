# coding: utf-8

require 'log'
require 'stream_data/message_entity_creator'
require 'stream_data/message_utils'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageEntity
  extend MessageEntityCreator
  include MessageUtils
  
  attr_reader :name
  attr_reader :file
  attr_reader :format
  attr_reader :values
  
  # コンストラクタ
  def initialize(name, file, format, values)
    raise "name is nil" if name.nil?
    raise "file is nil" if file.nil?
    raise "format is nil" if format.nil?
    raise "values is nil" if values.nil?
    
    @name = name
    @file = file
    @format = format
    @values = values
  end
  
  # 値をゲットする
  # @valuesになければ、@formatから取得する
  def get_value(key)
    raise "key is nil" if key.nil?
    return @format.get_value key if @values.nil?
    return @format.get_value key if @values[key].nil?
    return @values[key] 
  end
  
  # エンコード処理
  # @valuesを@formatでバイナリテキストにエンコードする
  # option:
  #   :binary バイナリにエンコードする
  def encode(option=nil)
    hex_string = ""
    @format.member_list.each do |member_name|
      member_data = @format.get_member member_name
      value = get_value member_name
      hex_string += member_data.encode value
    end
    return hex_string_to_binary hex_string if option == :binary
    return hex_string
  end
  
end

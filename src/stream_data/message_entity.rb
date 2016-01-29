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
  
  # メンバーリスト
  def member_list
    return @format.member_list
  end
  
  # メンバー合計サイズ
  def member_total_size
    return @format.member_total_size
  end
  
  # メンバー
  def members
    return @format.members
  end
  
  # 値をゲットする
  # @valuesになければ、@formatから取得する
  def get_value(key)
    raise "key is nil" if key.nil?
    return @format.get_value key if @values.nil?
    return @format.get_value key if @values[key].nil?
    return @values[key] 
  end
  
  # メンバーをゲットする
  def get_member(key)
    return @format.get_member key
  end
  
  # エンコード処理
  # @valuesを@formatでバイナリテキストにエンコードする
  # option:
  #   :binary バイナリにエンコードする
  def encode(variables, option=nil)
    hex_string = ""
    member_list.each do |member_name|
      member_data = get_member member_name
      value = get_value member_name
      if value.class == Symbol
        raise "not found value: [#{value}]" unless variables.has_key? value
        value = variables[value]
      end
      hex_string += member_data.encode value
    end
    return hex_string_to_binary hex_string if option == :binary
    return hex_string
  end
  
end

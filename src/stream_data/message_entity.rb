# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageEntity
  
  attr_reader :name
  attr_reader :file
  attr_reader :format
  attr_reader :values
  
  # コンストラクタ
  def initialize(name, file, format, values)
    @name = name
    @file = file
    @format = format
    @values = values
  end
  
  # 値をゲットする
  # @valuesになければ、@formatから取得する
  def get_value(key)
    return @format.get_value(key) if @values.nil?
    return @format.get_value(key) if @values[key].nil?
    return @values[key] 
  end
  
  # エンコード処理
  # @valuesを@formatでバイナリテキストにエンコードする
  def encode()
    hex_string = ""
    @format.member_list.each do |member_name|
      member_data = @format.get_member(member_name)
      value = get_value(member_name)
      hex_string += member_data.encode(value)
    end
    return hex_string
  end
  
end

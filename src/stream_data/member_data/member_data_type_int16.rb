# coding: utf-8

require 'stream_data/message_utils'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataTypeInt16
  include MessageUtils
  
  attr_reader :name_jp
  attr_reader :name
  attr_reader :type
  attr_reader :size
  attr_reader :offset
  attr_reader :default_value
  
  SIZE = 2
  DEFAULT_VALUE = 0
  
  # コンストラクタ
  def initialize(member, offset=nil)
    @name_jp = member['name_jp']
    @name = member['name']
    @type = member['type']
    @size = SIZE
    @offset = offset
    @default_value = DEFAULT_VALUE
  end
  
  def use_array?
    return true
  end
  
  def valid?(value)
    return false unless value.kind_of?(Integer)
    return false if value < 0 || value > (256 ** @size - 1)
    return true
  end
  
  # メッセージの長さが足りているかどうか
  def enough_length?(hex_string)
    return false if hex_string.length < @size*2
    return true
  end
  
  # デコード処理
  # バイナリテキストからデコードする
  def decode(hex_string)
    return nil unless enough_length?(hex_string)
    
    binary = hex_string_to_binary(hex_string)
    return binary_to_integer(binary)
  end
  
  # エンコード処理
  # バイナリテキストにエンコードする
  def encode(value=nil)
    value = @value if value.nil?
    return integer_to_hex_string(value, @size*2)
  end
  
end

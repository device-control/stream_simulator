# coding: utf-8

require 'stream_data/member_data_utils'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataTypeInt8
  include MemberDataUtils
  
  attr_reader :name_jp
  attr_reader :name
  attr_reader :type
  attr_reader :size
  attr_reader :hex_string_size
  attr_reader :offset
  attr_reader :default_value
  
  SIZE = 1
  DEFAULT_VALUE = 0
  
  # コンストラクタ
  def initialize(member, offset=nil)
    @name_jp = member['name_jp']
    @name = member['name']
    @type = member['type']
    @size = SIZE
    @hex_string_size = SIZE*2
    @offset = offset
    @default_value = DEFAULT_VALUE
  end
  
  def use_array?
    return true
  end
  
  def valid?(value)
    return false unless val.kind_of?(Integer)
    # raise "ERROR: #{self.class}##{__method__}: Not a target class of value. value=[#{val}] class=[#{val.class}]"
    return false if val < 0 || val > (256 ** @size - 1)
    # raise "ERROR: #{self.class}##{__method__}: Range is out of value. val=[#{val}]"
    return true
  end
  
  # メッセージの長さが足りているかどうか
  def enough_length?(hex_string)
    return false if hex_string.length < @hex_string_size
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

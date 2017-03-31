# coding: utf-8

require 'stream_data/member_data/member_data_type'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataTypeInt8 < MemberDataType
  SIZE = 1
  DEFAULT_VALUE = 0
  
  # コンストラクタ
  def initialize(member, offset=nil)
    super()
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
  
  # デコード処理
  # バイナリテキストからデコードする
  def decode(hex_string)
    raise "size error: expect=[#{@size*2}] actual=[#{hex_string.length}]" unless hex_string.length == @size*2
    binary = hex_string_to_binary(hex_string)
    return binary_to_integer(binary)
  end
  
  # エンコード処理
  # バイナリテキストにエンコードする
  def encode(value=nil)
    value = @value if value.nil?
    raise "invalid value: value=[#{value}]" unless valid? value
    return integer_to_hex_string(value, @size*2)
  end
  
  # 値を形成する
  def to_form(value)
    return sprintf("0x%0#{@size*2}X", value)
  end
  
end

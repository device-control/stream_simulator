# coding: utf-8

require 'stream_data/message_utils'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataTypeChar
  include MessageUtils
  
  attr_reader :name_jp
  attr_reader :name
  attr_reader :type
  attr_reader :size
  attr_reader :offset
  attr_reader :default_value
  
  SIZE = 1
  DEFAULT_VALUE = ''
  
  # コンストラクタ
  def initialize(member, offset=nil)
    @name_jp = member['name_jp']
    @name = member['name']
    @type = member['type']
    @size = SIZE
    @offset = offset
    @default_value = DEFAULT_VALUE
    
    # 配列の場合、サイズを配列数分に変更する
    @size = member['count'] * SIZE unless member['count'].nil?
  end
  
  def use_array?
    return false
  end
  
  def valid?(value)
    return false unless value.kind_of?(String)
    return false if value.bytesize > @size
    return true
  end
  
  # デコード処理
  # バイナリテキストからデコードする
  def decode(hex_string)
    raise "size error: expect=[#{@size*2}] actual=[#{hex_string.length}]" unless hex_string.length == @size*2
    binary = hex_string_to_binary(hex_string)
    return binary_to_ascii(binary)
  end
  
  # エンコード処理
  # バイナリテキストにエンコードする
  def encode(value=nil)
    value = @default_value if value.nil?
    raise "invalid value: value=[#{value}]" unless valid? value
    return ascii_to_hex_string(value, @size*2)
  end
  
  # 値を形成する
  def to_form(value)
    return "\"#{value}\""
  end
  
end

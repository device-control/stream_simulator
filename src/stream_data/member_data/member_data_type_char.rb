# coding: utf-8

require 'stream_data/member_data/member_data_utils'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataTypeChar
  include MemberDataUtils
  
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
    # raise "ERROR: #{self.class}##{__method__}: Not a target class of value. value=[#{val}] class=[#{val.class}]"
    return false if val.bytesize > @size
    # raise "ERROR: #{self.class}##{__method__}: Size is over. val=[#{val}] size=[#{val.bytesize}]"
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
    return binary_to_ascii(binary)
  end
  
  # エンコード処理
  # バイナリテキストにエンコードする
  def encode(value=nil)
    value = @default_value if value.nil?
    return ascii_to_hex_string(value, @size*2)
  end
  
end

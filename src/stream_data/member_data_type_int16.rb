# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'member_data_utils'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataTypeInt16
  include MemberDataUtils
  
  attr_reader :name_jp
  attr_reader :name
  attr_reader :type
  attr_reader :size
  attr_reader :hex_string_size
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
  
  def encode(value=nil)
    value = @value if value.nil?
    return integer_to_hex_string(value, @size*2)
  end
  
end

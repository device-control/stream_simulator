# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataTypeInt8
  
  attr_reader :name_jp
  attr_reader :name
  attr_reader :type
  attr_reader :size
  attr_accessor :offset
  attr_accessor :value
  
  SIZE = 1
  DEFAULT_VALUE = 0
  
  # コンストラクタ
  def initialize(member, offset=nil)
    @name_jp = member['name_jp']
    @name = member['name']
    @type = member['type']
    @size = SIZE
    @offset = offset
    @value = DEFAULT_VALUE
  end
  
  def use_array?
    return true
  end
  
  def value=(val)
    unless val.kind_of?(Integer)
      raise "ERROR: #{self.class}##{__method__}: Not a target class of value. value=[#{val}] class=[#{val.class}]"
    end
    if val < 0 || val > (256 ** @size - 1)
      raise "ERROR: #{self.class}##{__method__}: Range is out of value. val=[#{val}]"
    end
    @value = val
  end
  
end

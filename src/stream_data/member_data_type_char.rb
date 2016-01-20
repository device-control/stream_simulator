# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataTypeChar
  
  attr_reader :name_jp
  attr_reader :name
  attr_reader :type
  attr_reader :size
  attr_reader :offset
  attr_accessor :value
  
  SIZE = 1
  DEFAULT_VALUE = ''
  
  # コンストラクタ
  def initialize(member, offset=nil)
    @name_jp = member['name_jp']
    @name = member['name']
    @type = member['type']
    @size = SIZE
    @offset = offset
    @value = DEFAULT_VALUE
    
    # 配列の場合、サイズを配列数分に変更する
    @size = member['count'] * SIZE unless member['count'].nil?
  end
  
  def use_array?
    return false
  end
  
  def value=(val)
    unless val.kind_of?(String)
      raise "ERROR: #{self.class}##{__method__}: Not a target class of value. value=[#{val}] class=[#{val.class}]"
    end
    if val.bytesize > @size
      raise "ERROR: #{self.class}##{__method__}: Size is over. val=[#{val}] size=[#{val.bytesize}]"
    end
    @value = val
  end
  
end

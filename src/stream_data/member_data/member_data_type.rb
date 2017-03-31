# coding: utf-8

require 'stream_data/message_utils'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MemberDataType
  include MessageUtils
  
  attr_reader :name_jp
  attr_reader :name
  attr_reader :type
  attr_reader :size
  attr_reader :offset
  attr_reader :default_value
  
  # コンストラクタ
  def initialize
  end
  
  def add_offset(value)
    @offset += value
  end
end

# coding: utf-8

require 'log'
require 'stream_data/member_data_type_char'
require 'stream_data/member_data_type_int8'
require 'stream_data/member_data_type_int16'
require 'stream_data/member_data_type_int32'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MemberDataCreator
  
  def self.create(member, offset=nil)
    return MemberDataTypeChar.new(member, offset) if member['type'] == :CHAR
    return MemberDataTypeInt8.new(member, offset) if member['type'] == :INT8
    return MemberDataTypeInt16.new(member, offset) if member['type'] == :INT16
    return MemberDataTypeInt32.new(member, offset) if member['type'] == :INT32
    # 異常フォーマット
    raise "ERROR: #{self.class}##{__method__}: Undefined member type. name=[#{member['name']}] type=[#{member['type']}]"
  end
  
  def self.use_array?(member)
    return create(member).use_array?
  end
  
end

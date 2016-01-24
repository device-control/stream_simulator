# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "hashie"

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageFormat
  
  attr_reader :name
  attr_reader :file
  attr_reader :member_list
  attr_reader :member_total_size
  attr_reader :members
  attr_reader :primary_keys
  
  # コンストラクタ
  def initialize(name, file, member_list, member_total_size, members, primary_keys, values)
    @name = name
    @file = file
    @member_list = member_list
    @member_total_size = member_total_size
    @members = members
    @primary_keys = primary_keys
    @values = values
  end
  
  # 値をゲットする
  def get_value(key)
    return @values[key]
  end
  
  # メンバーをゲットする
  def get_member(key)
    begin
      hashie_members = Hashie::Mash.new @members
      return eval "hashie_members.#{key}"
    rescue => e
      raise "ERROR: #{self.class}##{__method__}: key=[#{key}] file=[#{@file}] " + e.message
    end
  end
  
  # 対象かどうか
  def target?(values)
    return false unless primary_keys_match?(values)
    return true
  end
  
  # プライマリキーが一致するかどうか
  def primary_keys_match?(values)
    return false if @primary_keys.nil?
    return false if @primary_keys.size == 0
    @primary_keys.each do |key, value|
      return false unless values.include?(key)
      return false unless values[key] == value
    end
    return true
  end
  
  # メッセージの長さが足りているかどうか
  def enough_length?(hex_string)
    return false if hex_string.length < @member_total_size*2
    return true
  end
  
  # デコード処理
  # @member_listをキーとしたHashにデコードする
  def decode(hex_string)
    return nil unless enough_length?(hex_string)
    
    values = Hash.new
    @member_list.each do |member_name|
      member_data = get_member(member_name)
      value = hex_string[member_data.offset, member_data.hex_string_size]
      values[member_name] = member_data.decode(value)
    end
    return values
  end
  
  # エンコード処理
  # バイナリテキストにエンコードする
  def encode()
    hex_string = ""
    @member_list.each do |member_name|
      member_data = get_member(member_name)
      value = get_value(member_name)
      hex_string += member_data.encode(value)
    end
    return hex_string
  end
  
end

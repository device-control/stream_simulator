# coding: utf-8

require 'hashie'

require 'log'
require 'stream_data/message_format_creator'
require 'stream_data/message_utils'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageFormat
  extend MessageFormatCreator
  include MessageUtils
  
  attr_reader :name
  attr_reader :file
  attr_reader :member_list
  attr_reader :member_total_size
  attr_reader :members
  attr_reader :values
  attr_reader :primary_keys
  
  # コンストラクタ
  def initialize(name, file, member_list, member_total_size, members, values, primary_keys)
    raise "name is nil" if name.nil?
    raise "file is nil" if file.nil?
    raise "member_list is nil" if member_list.nil?
    raise "member_total_size is nil" if member_total_size.nil?
    raise "members is nil" if members.nil?
    raise "values is nil" if values.nil?
    raise "primary_keys is nil" if primary_keys.nil?
    
    @name = name
    @file = file
    @member_list = member_list
    @member_total_size = member_total_size
    @members = members
    @values = values
    @primary_keys = primary_keys
  end
  
  def format
    return self
  end
  
  # 値をゲットする
  def get_value(key, override_values=nil)
    unless override_values.nil?
      return override_values[key] if override_values.has_key? key
    end
    return @values[key]
  end
  
  # メンバーをゲットする
  def get_member(key)
    begin
      hashie_members = Hashie::Mash.new @members
      return eval "hashie_members.#{key}"
    rescue => e
      raise "ERROR: #{self.class}\##{__method__}: key=[#{key}] file=[#{@file}] " + e.message
    end
  end
  
  # 対象かどうか
  def target?(values)
    return false unless primary_keys_match? values
    return true
  end
  
  # プライマリキーが一致するかどうか
  def primary_keys_match?(values)
    return false if @primary_keys.nil?
    return false if @primary_keys.size == 0
    @primary_keys.each do |key, value|
      return false unless values.include? key
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
    return nil unless enough_length? hex_string
    
    values = Hash.new
    @member_list.each do |member_name|
      member_data = get_member member_name
      value = hex_string[member_data.offset*2, member_data.size*2]
      values[member_name] = member_data.decode value
    end
    return values
  end
  
  # エンコード処理
  #   バイナリテキストにエンコードする
  # @param
  #   override_values ... [Hash] 上書きする値
  #   option          ... [Symbol] オプション
  #     :binary ... バイナリにエンコードする
  def encode(override_values=nil, option=nil)
    hex_string = ""
    @member_list.each do |member_name|
      member_data = get_member member_name
      value = get_value member_name, override_values
      hex_string += member_data.encode value
    end
    return hex_string_to_binary hex_string if option == :binary
    return hex_string
  end
  
  # すべてのメンバーと値を取得する
  # @param
  #   override_values ... [Hash] 上書きする値
  # @return
  #   all_members ... [Array] すべてのメンバーのリスト
  #     all_members[n] ... [Hash] メンバー
  #       :name         ... [String] メンバー名
  #       :value        ... [Object] 値
  #       :member_data  ... [Object] メンバーデータ
  def get_all_members_with_values(override_values=nil)
    all_members = Array.new
    @member_list.each do |member_name|
      member_data = get_member member_name
      value = get_value member_name, override_values
      member = Hash.new
      member[:name] = member_name
      member[:member_data] = member_data
      member[:value] = value
      all_members << member
    end
    return all_members
  end
  
  # 比較する
  # @param
  #   message   ... [Object] 比較するメッセージのオブジェクト
  #   override_values ... [Hash] 上書きする値
  # @return
  #   result  ... [true/false] 比較結果
  #   details ... [Hash] 詳細
  #     :reason ... [Symbol] 理由 :different_format
  def compare(message, override_values=nil)
    result = true
    details = Hash.new
    # フォーマット名が一致するかどうか
    unless @name == message.format.name
      result = false
      details[:reason] = :different_format
    end
    return result, details
  end
  
end

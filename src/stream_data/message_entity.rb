# coding: utf-8

require 'log'
require 'stream_data/message_entity_creator'
require 'stream_data/message_utils'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageEntity
  extend MessageEntityCreator
  include MessageUtils
  
  attr_reader :name
  attr_reader :file
  attr_reader :format
  attr_reader :values
  
  # コンストラクタ
  def initialize(name, file, format, values)
    raise "name is nil" if name.nil?
    raise "file is nil" if file.nil?
    raise "format is nil" if format.nil?
    raise "values is nil" if values.nil?
    
    @name = name
    @file = file
    @format = format
    @values = values
  end
  
  # メンバーリスト
  def member_list
    return @format.member_list
  end
  
  # メンバー合計サイズ
  def member_total_size
    return @format.member_total_size
  end
  
  # メンバー
  def members
    return @format.members
  end
  
  # 値をゲットする
  # @foramtから取得し、@valuesにあれば上書きする
  def get_value(key, override_values=nil)
    value = @format.get_value key
    unless @values.nil?
      value = @values[key] if @values.has_key? key
    end
    unless override_values.nil?
      value = override_values[key] if override_values.has_key? key
    end
    return value
  end
  
  # メンバーをゲットする
  def get_member(key)
    return @format.get_member key
  end
  
  # エンコード処理
  #   @valuesを@formatでバイナリテキストにエンコードする
  # @param
  #   override_values ... [Hash] 上書きする値
  #   option          ... [Symbol] オプション
  #     :binary ... バイナリにエンコードする
  def encode(override_values=nil, option=nil)
    hex_string = ""
    member_list.each do |member_name|
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
  #       :name        ... [String] メンバー名
  #       :member_data ... [Object] メンバーデータ
  #       :value       ... [Object] 値
  def get_all_members_with_values(override_values=nil)
    all_members = Array.new
    member_list.each do |member_name|
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
  #   message         ... [Object] 比較するメッセージのオブジェクト
  #   override_values ... [Hash] 上書きする値
  # @return
  #   result  ... [true/false] 比較結果
  #   details ... [Hash] 詳細
  #     :reason                 ... [Symbol] 理由 :different_format or :different_values
  #     :difference_member_list ... [Array] 差異のあるメンバーリスト
  #       difference_member_list[n] ... [Hash] 差異のあるメンバー
  #         :name           ... [String] メンバー名
  #         :value          ... [Object] 値
  #         :compared_value ... [Object] 比較した値
  def compare(message, override_values=nil)
    # フォーマット比較
    result, details = @format.compare message
    if result == false
      return result, details
    end
    
    # 値が一致するかどうか
    difference_member_list = Array.new
    member_list.each.with_index(0) do |member_name, index|
      member_data = get_member member_name
      value = get_value member_name, override_values
      compared_value = message.get_value member_name
      
      unless value == compared_value
        member = Hash.new
        member[:name] = member_name
        member[:value] = member_data.to_form value
        member[:compared_value] = member_data.to_form compared_value
        difference_member_list << member
      end
    end
    
    result = true
    details = Hash.new
    if difference_member_list.length > 0
      result = false
      details[:reason] = :different_values
      details[:difference_member_list] = difference_member_list
    end
    return result, details
  end
  
end

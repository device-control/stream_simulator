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
  attr_reader :primary_key
  
  # コンストラクタ
  def initialize(name, file, member_list, member_total_size, members, primary_key)
    @name = name
    @file = file
    @member_list = member_list
    @member_total_size = member_total_size
    @members = members
    @primary_key = primary_key
  end
  
  # 値をセットする
  def set_value(key, value)
    begin
      hashie_members = Hashie::Mash.new @members
      eval "hashie_members.#{key}.value = value"
    rescue => e
      raise "ERROR: #{self.class}##{__method__}: key=[#{key}] value=[#{value}] file=[#{@file}] " + e.message
    end
  end
  
  
  
  # # 対象のメッセージかどうか
  # def target?(message)
  #   return false if message.length < @message_length
  #   return false unless check_primary_key(message)
  #   return true
  # end
  
  # # プライマリキーのチェック
  # def check_primary_key(message)
  #   return false if @primary_key.nil?
  #   @primary_key.each do |key|
  #     data = message[key[POSITION], type_message_length(key[TYPE])]
  #     value = hex_string_to_typedata(data, key[TYPE])
  #     return false unless value == key[VALUE]
  #   end
  #   return true
  # end
  
  # # デコード
  # # メッセージ（バイナリテキスト）から
  # # フォーマットのデータ（Array）を生成する
  # def decode(message)
  #   # メッセージ長のチェック
  #   if message.length < @message_length
  #     raise "#{self.class}##{__method__}: message length is missing."
  #   end
    
  #   # フォーマットのデータに変換する
  #   data = Array.new
  #   @format.each do |f|
  #     temp_data = message[f[POSITION], type_message_length(f[TYPE])]
  #     value = hex_string_to_typedata(temp_data, f[TYPE])
      
  #     struct = Hash.new
  #     struct[NAME] = f[NAME]
  #     struct[VALUE] = value
  #     data.push(struct)
  #   end
  #   return data
  # end
  
  # # エンコード
  # # フォーマットのデータ（Array）から
  # # メッセージ（バイナリテキスト）を生成する
  # def encode(data=nil)
  #   message = ""
  #   @format.each.with_index(0) do |f,index|
  #     if data.nil?
  #       value = f[DEFAULT_VALUE]
  #     else
  #       d = data[index]
  #       if d[NAME] != f[NAME]
  #         raise "#{self.class}##{__method__}: unmatch key. #{f[NAME]}"
  #       end
  #       value = d[VALUE]
  #       if value.nil?
  #         raise "#{self.class}##{__method__}: no data found. #{f[NAME]}"
  #       end
  #     end
  #     message += typedata_to_hex_string(value, f[TYPE])
  #   end
  #   return message
  # end
  
end

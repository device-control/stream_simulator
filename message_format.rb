# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'
require 'message_utils'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageFormat
  include MessageUtils
  
  TARGET_CONTENT_TYPE    = 'message_format'
  TARGET_CONTENT_VERSION = '0.1'
  
  NAME          = 'name'
  NAME_JP       = 'name_jp'
  DESCRIPTION   = 'description'
  PRIMARY_KEY   = 'primary_key'
  FORMAT        = 'format'
  TYPE          = 'type'
  VALUE         = 'value'
  DEFAULT_VALUE = 'default_value'
  POSITION      = 'position'
  
  attr_accessor :name
  attr_accessor :description
  attr_accessor :primary_key
  attr_accessor :format
  attr_accessor :default_data
  attr_accessor :length
  attr_reader   :file_path
  # コンストラクタ
  def initialize(contents,file=nil)
    create_contents(contents,file)
  end
  
  # コンテンツを生成
  def create_contents(contents,file=nil)
    @file_path = file
    @name = contents[NAME]
    @description = contents[DESCRIPTION]
    create_primary_key(contents)
    create_format(contents)
    create_default_data(contents)
    create_length(contents)
  end
  
  # プライマリキーを生成する
  def create_primary_key(contents)
    return if contents[PRIMARY_KEY].nil?
    
    @primary_key = Array.new
    contents[PRIMARY_KEY].each do |key|
      struct = Hash.new
      struct[NAME] = key[NAME]
      struct[VALUE] = key[VALUE]
      
      # フォーマットからキーを検索し、位置と型を取得する
      position = 0
      contents[FORMAT].each do |f|
        if key[NAME] == f[NAME]
          struct[TYPE] = f[TYPE]
          struct[POSITION] = position
          break
        end
        position += type_length(f[TYPE])
      end
      
      # キーがフォーマットになければ異常
      if struct[POSITION].nil? || struct[TYPE].nil?
        raise "#{self.class}##{__method__}: #{key[NAME]} does not exist in the format."
      end
      
      @primary_key.push(struct)
    end
  end
  
  # フォーマットを生成する
  def create_format(contents)
    @format = Array.new
    
    position = 0
    contents[FORMAT].each do |f|
      struct = Hash.new
      struct[NAME] = f[NAME]
      struct[NAME_JP] = f[NAME_JP]
      struct[TYPE] = f[TYPE]
      struct[DEFAULT_VALUE] = f[DEFAULT_VALUE]
      struct[POSITION] = position
      @format.push(struct)
      
      position += type_length(f[TYPE])
    end
  end
  
  # デフォルトデータを生成する
  def create_default_data(contents)
    @default_data = Array.new
    
    contents[FORMAT].each do |f|
      struct = Hash.new
      struct[NAME] = f[NAME]
      struct[VALUE] = f[DEFAULT_VALUE]
      @default_data.push(struct)
    end
  end
  
  # メッセージ長を生成する
  def create_length(contents)
    len = 0
    contents[FORMAT].each do |f|
      type = f[TYPE]
      len += type_length(type)
    end
    @length = len
  end
  
  # 対象のメッセージかどうか
  def target?(message)
    return false if message.length < @length
    return false unless check_primary_key(message)
    return true
  end
  
  # プライマリキーのチェック
  def check_primary_key(message)
    return false if @primary_key.nil?
    
    @primary_key.each do |key|
      position = key[POSITION]
      type = key[TYPE]
      
      data = message[position, type_length(type)]
      value = convert_format(data, type)
      
      return false unless value == key[VALUE]
    end
    return true
  end
  
  # デコード
  def decode(message)
    # メッセージ長のチェック
    if message.length < @length
      raise "#{self.class}##{__method__}: message length is missing."
    end
    
    # フォーマットのデータに変換する
    datas = Array.new
    @format.each do |f|
      name = f[NAME]
      position = f[POSITION]
      type = f[TYPE]
      
      data = message[position, type_length(type)]
      value = convert_format(data, type)
      
      struct = Hash.new
      struct[NAME] = name
      struct[VALUE] = value
      datas.push(struct)
    end
    return datas
  end
  
  # エンコード
  def encode(data=nil)
    if data == nil
      # デフォルト値を取得する
      return get_default_value
    end
    message = ""
    @format.each.with_index(0) do |f,index|
      d = data[index]
      if d[NAME] != f[NAME]
        raise "#{self.class}##{__method__}: unmatch key. #{f[NAME]}"
      end
      value = d[VALUE]
      if value.nil?
        raise "#{self.class}##{__method__}: no data found. #{f[NAME]}"
      end
      message += convert_message(value, f[TYPE])
    end
    ret = convert_binary(message)
    return ret
  end

  def get_default_value
    message = ""
    @format.each.with_index(0) do |f,index|
      message += convert_message(f[DEFAULT_VALUE], f[TYPE])
    end
    # puts "bin[#{message}]"
    ret = convert_binary(message)
    return ret
  end

end

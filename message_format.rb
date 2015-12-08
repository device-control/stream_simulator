# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageFormat
  
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
  
  # コンストラクタ
  def initialize(contents)
    create_contents(contents)
  end
  
  # コンテンツを生成
  def create_contents(contents)
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
  def encode(data)
    message = ""
    @format.each do |f|
      name = f[NAME]
      type = f[TYPE]
      
      value = nil
      data.each do |d|
        if name == d[NAME]
          value = d[VALUE]
          break
        end
      end
      
      if value.nil?
        raise "#{self.class}##{__method__}: no data found. #{name}"
      end
      
      message += convert_message(value, type)
    end
    ret = convert_binary(message)
    return ret
  end
  
  # フォーマットのデータに変換する
  def convert_format(data, type)
    # char型
    if type =~ /^char.*/
      return convert_ascii(data)
    end
    # int型
    array_count = type_array_count(type)
    if array_count == 1
      return convert_integer(data)
    else
      # バイナリテキストに変換
      buf = data.unpack('C*')
      ret = convert_hex_string(buf)
      return ret
    end
  end
  
  # メッセージのデータに変換する
  def convert_message(data, type)
    length = type_length(type) * 2
    # char型
    if type =~ /^char.*/
      ret = convert_hex_string(data)
      # 不足分は0で埋める
      if (length - ret.length) > 0
        ret += sprintf("%0#{length-ret.length}X", 0)
      end
      return ret
    end
    # int型
    array_count = type_array_count(type)
    if array_count == 1
      ret = sprintf("%0#{length}X", data)
      return ret
    else
      # バイナリテキストに変換
      ret = data
      # 不足分は0で埋める
      if (length - ret.length) > 0
        ret += sprintf("%0#{length-ret.length}X", 0)
      end
      return ret
    end
    
  end
  
  # ASCII文字に変換
  def convert_ascii(data)
    ret = data.unpack("A*").pop
    return ret
  end

  # 整数に変換
  def convert_integer(data)
    buf = data.unpack('C*')
    ret = 0
    buf.each do |b|
      ret = (ret << 8) | b
    end
    return ret
  end
  
  # バイナリテキストに変換
  def convert_hex_string(data)
    ret = data.scan(/.{1}/).collect{|c| sprintf("%02X", c.ord)}.join
    return ret
  end
  
  # バイナリに変換
  def convert_binary(data)
    ret = data.scan(/.{2}/).collect{|c| c.hex}.pack("C*")
    return ret
  end
  
  # 型のバイト長
  def type_length(type)
    count = type_array_count(type)
    size = type_size(type)
    return count * size
  end
  
  # 型の配列数
  def type_array_count(type)
    count = 1
    type.match(/^.+\[(.+)\]$/) do |m|
      count = m[1].to_i
    end
    return count
  end
  
  # 型のサイズ
  def type_size(type)
    return 1 if type =~ /^char.*/
    return 1 if type =~ /^int8.*/
    return 2 if type =~ /^int16.*/
    return 4 if type =~ /^int32.*/
    raise "#{self.class}##{__method__}: structure type is invalid. #{type}"
  end
  
end

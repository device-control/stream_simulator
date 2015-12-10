# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageUtils

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
      return data.unpack('H*')[0]
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

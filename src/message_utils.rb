# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageUtils

  # message_format の contents 以下が正しいフォーマットか確認する
  def message_format_contents?(contents)
    begin
      emb = "Error:#{self.class}##{__method__}:"
      raise "#{emb}: Undefined \"name\"" if contents["name"].nil?
      raise "#{emb}: Undefined \"description\"" if contents["description"].nil?
      # プライマリキー存在している場合、項目確認
      if !contents["primary_key"].nil?
        contents["primary_key"].each do |key|
          raise "#{emb}: Undefined \"primary_key/name\"]" if key["name"].nil?
          raise "#{emb}: Undefined \"primary_key/name\"]" if key["value"].nil?
        end
      end
      "#{emb}: Undefined \"format\"" if contents["format"].nil?
      contents["format"].each.with_index(0) do |format,index|
        raise "#{emb}: Undefined \"format[#{index}]/name\"]"          if format["name"].nil?
        raise "#{emb}: Undefined \"format[#{index}]/name_jp\"]"       if format["name_jp"].nil?
        raise "#{emb}: Undefined \"format[#{index}]/type\"]"          if format["type"].nil?
        raise "#{emb}: Undefined \"format[#{index}]/default_value\"]" if format["default_value"].nil?
        
        # サイズ確認（デフォルト値がtype指定したものよりサイズがオーバーしていないか確認
        # ただし、type="int8" で default_value=0x00000001 のように、は見た目オーバーしているが
        # default_value=0x01 として処理する。
        length = type_length(format["type"])
        bin_string = typedata_to_hex_string(format["default_value"], format["type"])
        raise "#{emb}: size over \"format[#{index}] #{format["name"]} [#{bin_string}]" if bin_string.length != (length * 2)
      end 
    rescue => e
      raise e.message
    end
    return true
  end
  
  # バイナリテキストをTypeデータに変換する
  def hex_string_to_typedata(data, type)
    # バイナリテキストをバイナリに変換
    binary = hex_string_to_binary(data)
    return binary_to_typedata(binary, type)
  end

  # バイナリをTypeデータに変換する
  def binary_to_typedata(data, type)
    # char型
    # ASCIIに変換
    if type =~ /^char.*/
      return binary_to_ascii(data)
    end
    # int型
    array_count = type_array_count(type)
    if array_count == 1
      # 配列でなければ、integerに変換
      return binary_to_integer(data)
    else
      # 配列なら、バイナリテキストに変換
      return data.unpack('H*')[0]
    end
  end
  
  # Typeデータをバイナリテキストに変換する
  def typedata_to_hex_string(data, type)
    length = type_message_length(type)
    # char型
    if type =~ /^char.*/
      ret = binary_to_hex_string(data)
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
  
  # バイナリをASCII文字に変換
  def binary_to_ascii(data)
    ret = data.unpack("A*").pop
    return ret
  end

  # バイナリを整数に変換
  def binary_to_integer(data)
    buf = data.unpack('C*')
    ret = 0
    buf.each do |b|
      ret = (ret << 8) | b
    end
    return ret
  end
  
  # バイナリをバイナリテキストに変換
  def binary_to_hex_string(data)
    ret = data.bytes.collect{|ch|sprintf "%02X",ch.ord}.join
    return ret
  end
  
  # バイナリテキストをバイナリに変換
  def hex_string_to_binary(data)
    ret = data.scan(/.{2}/).collect{|c| c.hex}.pack("C*")
    return ret
  end
  
  # 型のメッセージ長
  def type_message_length(type)
    return type_length(type) * 2
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

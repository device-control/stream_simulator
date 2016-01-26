# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MemberDataUtils
  
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
  
  # ASCII文字をバイナリテキストに変換
  def ascii_to_hex_string(data, hex_length)
    ret = binary_to_hex_string(data)
    
    # ０埋め
    padding_size = hex_length - ret.length
    if (padding_size) > 0
      ret += sprintf("%0#{padding_size}X", 0)
    end
    return ret
  end
  
  # 整数をバイナリテキストに変換
  def integer_to_hex_string(data, hex_length)
    return sprintf("%0#{@hex_length}X", data)
  end
  
  # バイナリをバイナリテキストに変換
  def binary_to_hex_string(data)
    return data.bytes.collect{|ch|sprintf "%02X",ch.ord}.join
  end
  
  # バイナリテキストをバイナリに変換
  def hex_string_to_binary(data)
    ret = data.scan(/.{2}/).collect{|c| c.hex}.pack("C*")
    return ret
  end
  
end

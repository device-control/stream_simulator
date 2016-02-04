# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageUtils
  
  # バイナリをバイナリテキストに変換
  # "\x00\x01\02\03" => "00010203" 
  def binary_to_hex_string(data)
    return data.bytes.collect{|ch|sprintf "%02X",ch.ord}.join
  end
  
  # バイナリテキストをバイナリに変換
  # "\x00\x01\02\03" <= "00010203" 
  def hex_string_to_binary(data)
    return data.scan(/.{2}/).collect{|c| c.hex}.pack("C*")
  end
  
  # バイナリをASCII文字に変換
  # "\x41\x42\x43\x44\x00\x00" => "ABCD"
  # "ABCD\0\0" => "ABCD"
  # 文字列から最初に見つかったNULL文字以降が削除
  def binary_to_ascii(data)
    return data.sub(/\0.*/m,'')
    # return data.gsub(/\x00.+/,'') # これだと上手くNULLを削除できない
  end
  
  # バイナリを整数に変換
  # "\x00\x00\x00\x00" => 1234
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
    return sprintf("%0#{hex_length}X", data)
  end
  
end

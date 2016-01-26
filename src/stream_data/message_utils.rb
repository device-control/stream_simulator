# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageUtils
  
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
  
end

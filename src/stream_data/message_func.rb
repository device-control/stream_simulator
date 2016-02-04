# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageFunc
  
  # ビット値変換
  # bit_index  : ビット位置
  # bit_length : ビット長
  # value      : 値
  def bit(bit_index, bit_length, value)
    begin
      bit_index = eval bit_index if bit_index.class != Fixnum
      bit_length = eval bit_length if bit_index.class != Fixnum
      value = eval value if bit_index.class != Fixnum
      max = (1 << bit_length) - 1
      raise "out of bit length" if value > max 
      value <<= bit_index
    rescue => e
      raise e.message + ": invalid parameters [#{bit_index}][#{bit_length}][#{value}]."
    end
  end
  
end

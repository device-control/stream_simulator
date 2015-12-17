# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# TODO: 関数名から意味がわかるよう修正する必要がある。
#       あと、入力と出力がわかるようにする必要がある。

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
        bin_string = convert_message(format["default_value"], format["type"])
        raise "#{emb}: size over \"format[#{index}] #{format["name"]} [#{bin_string}]" if bin_string.length != (length * 2)
      end 
    rescue => e
      raise e.message
    end
    return true
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

# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream_data'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream_runner'))

require 'message_utils'
require 'log'
require 'yaml_reader'

require 'pry'

class Mock
  extend MessageUtils
end


describe 'MessageUtils' do
  before do
    log = Log.instance
    log.disabled
  end

  context 'hex_string_to_typedata' do
    # hex_string_to_typedata(data,type) 仕様
    #  data = バイナリテキスト
    #  type = int8,int16,int32 x n
    # 結果
    #  配列でない：整数
    #  配列の場合：バイナリテキスト
    it 'フォーマットデータに変換できること' do
      # int8
      expect(Mock.hex_string_to_typedata 'FF', "int8").to eq 0xFF
      # int16
      expect(Mock.hex_string_to_typedata '0123', "int16").to eq 0x0123
      # int32
      expect(Mock.hex_string_to_typedata '01234567', "int32").to eq 0x01234567
      
      # 配列
      # char
      expect(Mock.hex_string_to_typedata "ABC".each_char.collect{|ch|sprintf "%02X",ch.ord}.join, "char[3]" ).to eq "ABC"
      # int8[2]
      expect(Mock.hex_string_to_typedata "0123", "int8[2]").to eq "0123"
      # int16[2]
      expect(Mock.hex_string_to_typedata "01234567", "int16[2]").to eq "01234567"
      # int32[2]
      expect(Mock.hex_string_to_typedata "0123456701234567", "int32[2]").to eq "0123456701234567"
    end
  end

  context 'binary_to_typedata' do
    # binary_to_typedata(data,type) 仕様
    #  data = バイナリー
    #  type = int8,int16,int32 x n
    # 結果
    #  配列でない：整数
    #  配列の場合：バイナリテキスト
    it 'フォーマットデータに変換できること' do
      # int8
      expect(Mock.binary_to_typedata ['FF'].pack("H*"), "int8").to eq 0xFF
      # int16
      expect(Mock.binary_to_typedata ['0123'].pack("H*"), "int16").to eq 0x0123
      # int32
      expect(Mock.binary_to_typedata ['01234567'].pack("H*"), "int32").to eq 0x01234567
      
      # 配列
      # char
      expect(Mock.binary_to_typedata "ABC", "char[3]" ).to eq "ABC"
      # int8[2]
      expect(Mock.binary_to_typedata ["0123"].pack("H*"), "int8[2]").to eq "0123"
      # int16[2]
      expect(Mock.binary_to_typedata ["01234567"].pack("H*"), "int16[2]").to eq "01234567"
      # int32[2]
      expect(Mock.binary_to_typedata ["0123456701234567"].pack("H*"), "int32[2]").to eq "0123456701234567"
    end
  end

  context 'typedata_to_hex_string' do
    # typedata_to_hex_string(data,type) 仕様
    # 配列でない場合
    #  type = int8,int16,int32 x 1
    #   data = 整数
    #  type = char x 1
    #   data = 文字列
    # 
    # 配列の場合
    #  type = int8,int16,int32 x n
    #   data = バイナリーテキスト
    #  type = char x n
    #   data = 文字列
    # 結果
    #  バイナリテキスト
    it 'メッセージデータに変換できること' do
      # data = バイナリーテキスト
      # type = char,int8,int16,int32 x array
      
      # int8
      expect(Mock.typedata_to_hex_string 0xff, "int8").to eq "FF"
      # int16
      expect(Mock.typedata_to_hex_string 0x0123, "int16").to eq "0123"
      # int32
      expect(Mock.typedata_to_hex_string 0x01234567, "int32").to eq "01234567"
      
      # 配列
      # char
      expect(Mock.typedata_to_hex_string "ABC", "char[3]").to eq "ABC".each_char.collect{|ch|sprintf "%02X",ch.ord}.join
      # int8[2]
      expect(Mock.typedata_to_hex_string "0123", "int8[2]").to eq "0123"
      # int16[2]
      expect(Mock.typedata_to_hex_string "01234567", "int16[2]").to eq "01234567"
      # int32[2]
      expect(Mock.typedata_to_hex_string "0123456701234567", "int32[2]").to eq "0123456701234567"
    end
  end

  context 'binary_to_ascii' do
    it '文字列からnull文字が削除されること' do
      expect(Mock.binary_to_ascii "ABCDEF\0").to eq "ABCDEF"
    end
  end

  context 'binary_to_integer' do
    it 'バイナリから整数に変換できること' do
      bin = ['00010203'].pack("H*")
      expect(Mock.binary_to_integer bin).to eq 0x00010203
    end
  end
  
  context 'binary_to_hex_string' do
    it '文字列からバイナリストリグに変換できること' do
      string = '0123456789ABCDEFG'
      actual = string.each_char.collect{|ch|sprintf "%02X",ch.ord}.join
      expect(Mock.binary_to_hex_string string ).to eq actual
      # 改行コードが含まれるパターン
      string = "\x00\x01\r\n\x02\x03\n"
      actual = "00010D0A02030A"
      expect(Mock.binary_to_hex_string string ).to eq actual
    end
  end

  context 'hex_string_to_binary' do
    it 'バイナリストリグからバイナリに変換できること' do
      bin_string = '000102030405060708'
      expect(Mock.hex_string_to_binary bin_string).to eq [bin_string].pack("H*")
      # 改行コードが含まれるパターン
      bin_string = '12345678900AABCDEF0D0A00'
      expect(Mock.hex_string_to_binary bin_string).to eq [bin_string].pack("H*")
    end
  end

  context 'type_message_length' do
    it '型のバイト長が正しく取得できること' do
      expect(Mock.type_message_length 'int8').to eq 2
      expect(Mock.type_message_length 'int8[10]').to eq 20
      expect(Mock.type_message_length 'char').to eq 2
      expect(Mock.type_message_length 'char[10]').to eq 20
      expect(Mock.type_message_length 'int16').to eq 4
      expect(Mock.type_message_length 'int16[10]').to eq 40
      expect(Mock.type_message_length 'int32').to eq 8
      expect(Mock.type_message_length 'int32[10]').to eq 80
    end
  end

  context 'type_length' do
    it '型のバイト長が正しく取得できること' do
      expect(Mock.type_length 'int8').to eq 1
      expect(Mock.type_length 'int8[10]').to eq 10
      expect(Mock.type_length 'char').to eq 1
      expect(Mock.type_length 'char[10]').to eq 10
      expect(Mock.type_length 'int16').to eq 2
      expect(Mock.type_length 'int16[10]').to eq 20
      expect(Mock.type_length 'int32').to eq 4
      expect(Mock.type_length 'int32[10]').to eq 40
    end
  end

  context 'type_array_count' do
    it '型の配列数が正しく取得できること' do
      expect(Mock.type_array_count 'int8').to eq 1
      expect(Mock.type_array_count 'int8[10]').to eq 10
      expect(Mock.type_array_count 'char').to eq 1
      expect(Mock.type_array_count 'char[10]').to eq 10
      expect(Mock.type_array_count 'int16').to eq 1
      expect(Mock.type_array_count 'int16[10]').to eq 10
      expect(Mock.type_array_count 'int32').to eq 1
      expect(Mock.type_array_count 'int32[10]').to eq 10
    end
  end
  
  context 'type_size' do
    it '型のサイズが正しく取得できること' do
      expect(Mock.type_size 'int8').to eq 1
      expect(Mock.type_size 'int8[10]').to eq 1
      expect(Mock.type_size 'char').to eq 1
      expect(Mock.type_size 'char[10]').to eq 1
      expect(Mock.type_size 'int16').to eq 2
      expect(Mock.type_size 'int16[10]').to eq 2
      expect(Mock.type_size 'int32').to eq 4
      expect(Mock.type_size 'int32[10]').to eq 4
      # 参考 https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/raise-error-matcher
      expect{Mock.type_size 'float'}.to raise_error(RuntimeError)
    end
  end

  
end

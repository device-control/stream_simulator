# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'stream_data/message_utils'
require 'log'
require 'pry'

describe 'MessageUtils' do
  log = Log.instance
  log.disabled
  let(:mock_class) { Struct.new(:test) { include MessageUtils} }
  let(:target) { mock_class.new }

  
  before do
  end

  context 'binary_to_hex_string' do
    it 'バイナリをバイナリーテキストに変換できること' do
      bin_texts = [
        '00',
        '7F',
        '80',
        'FF',
        'FFFF',
        'FFFFFFFF',
        '000102030405060708', # 適当
        '12345678900AABCDEF0D0A00', # 適当+改行含む
        '12345678900AABCDEF0D00FF', # 適当+改行含む
        '12345678900AABCDEF0A00FF', # 適当+改行含む
      ]
      bin_texts.each do |bin_text|
        expect(target.binary_to_hex_string [bin_text].pack("H*")).to eq bin_text
      end
    end
  end

  context 'hex_string_to_binary' do
    it 'バイナリテキストをバイナリに変換できること' do
      bin_texts = [
        '00',
        '7F',
        '80',
        'FF',
        'FFFF',
        'FFFFFFFF',
        '000102030405060708', # 適当
        '12345678900AABCDEF0D0A00', # 適当+改行含む
        '12345678900AABCDEF0D00FF', # 適当+改行含む
        '12345678900AABCDEF0A00FF', # 適当+改行含む
      ]
      bin_texts.each do |bin_text|
        expect(target.hex_string_to_binary bin_text).to eq [bin_text].pack("H*")
      end
    end
  end

  context 'binary_to_ascii' do
    it '文字列から最初に見つかったnull文字以降が削除されること' do
      expect(target.binary_to_ascii "1ABCDEF").to eq "1ABCDEF"
      expect(target.binary_to_ascii "2ABCDEF\0").to eq "2ABCDEF"
      expect(target.binary_to_ascii "3ABCDEF\x00").to eq "3ABCDEF"
      expect(target.binary_to_ascii "4ABC\nDEF\0\r\n").to eq "4ABC\nDEF"
    end
  end

  context 'binary_to_integer' do
    it 'バイナリから整数に変換できること' do
      bin_texts = [
        '00',
        '7F',
        '80',
        'FF',
        '0000',
        '7FFF',
        '8000',
        'FFFF',
        '00000000',
        '7FFFFFFF',
        '80000000',
        'FFFFFFFF',
      ]
      bin_texts.each do |bin_text|
        bin = [bin_text].pack("H*")
        expect(target.binary_to_integer bin).to eq bin_text.hex
      end
    end
  end

  context 'ascii_to_hex_string' do
    it 'ASCII文字をバイナリテキストに変換できること' do
      texts = [
        "ABC",
        "ABC\rDEF",
        "ABC\nDEF",
        "ABC\r\nDEF",
        "ABC\nDEF\0\0\0",
      ]
      texts.each do |text|
        expect(target.ascii_to_hex_string text, text.size).to eq text.unpack("H*").pop.upcase
      end
      # サイズをゼロで拡張
      texts.each do |text|
        expect(target.ascii_to_hex_string text, 20).to eq text.unpack("H*").pop.upcase + ("00" * ((20/2) - (text.size)))
      end
    end
  end
end

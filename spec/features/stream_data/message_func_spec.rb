# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'stream_data/message_func'
require 'log'
require 'pry'

describe 'MessageFunc' do
  log = Log.instance
  log.disabled
  let(:mock_class) { Struct.new(:test) { include MessageFunc} }
  let(:target) { mock_class.new }
  
  before do
  end

  context 'bit' do
    it 'bit演算できること' do
      expect(target.bit 0, 1, 1).to eq 1
      expect(target.bit 1, 1, 1).to eq 2
      expect(target.bit 2, 1, 1).to eq 4
      expect(target.bit 3, 1, 1).to eq 8
      expect(target.bit 4, 1, 1).to eq 16
      expect(target.bit 5, 1, 1).to eq 32
      expect(target.bit 6, 1, 1).to eq 64
      expect(target.bit 7, 1, 1).to eq 128

      expect(target.bit 0, 7, 128 - 1).to eq (128 - 1) << 0
      expect(target.bit 1, 7, 128 - 1).to eq (128 - 1) << 1
      expect(target.bit 2, 7, 128 - 1).to eq (128 - 1) << 2
      expect(target.bit 3, 7, 128 - 1).to eq (128 - 1) << 3
      expect(target.bit 4, 7, 128 - 1).to eq (128 - 1) << 4
      expect(target.bit 5, 7, 128 - 1).to eq (128 - 1) << 5
      expect(target.bit 6, 7, 128 - 1).to eq (128 - 1) << 6
      expect(target.bit 7, 7, 128 - 1).to eq (128 - 1) << 7

      expect(target.bit 0, 1,   2 - 1).to eq   2 - 1
      expect(target.bit 0, 2,   4 - 1).to eq   4 - 1
      expect(target.bit 0, 3,   8 - 1).to eq   8 - 1
      expect(target.bit 0, 4,  16 - 1).to eq  16 - 1
      expect(target.bit 0, 5,  32 - 1).to eq  32 - 1
      expect(target.bit 0, 6,  64 - 1).to eq  64 - 1
      expect(target.bit 0, 7, 128 - 1).to eq 128 - 1
      expect(target.bit 0, 8, 256 - 1).to eq 256 - 1
    end
    
    it 'bit演算でビット長異常例外が発生すること' do
      expect{target.bit 0, 1, 2}.to raise_error StandardError
      expect{target.bit 1, 1, 2}.to raise_error StandardError
      expect{target.bit 2, 1, 2}.to raise_error StandardError
      expect{target.bit 3, 1, 2}.to raise_error StandardError
      expect{target.bit 4, 1, 2}.to raise_error StandardError
      expect{target.bit 5, 1, 2}.to raise_error StandardError
      expect{target.bit 6, 1, 2}.to raise_error StandardError
      expect{target.bit 7, 1, 2}.to raise_error StandardError

      expect{(target.bit 0, 7, 128)}.to raise_error StandardError
      expect{(target.bit 1, 7, 128)}.to raise_error StandardError
      expect{(target.bit 2, 7, 128)}.to raise_error StandardError
      expect{(target.bit 3, 7, 128)}.to raise_error StandardError
      expect{(target.bit 4, 7, 128)}.to raise_error StandardError
      expect{(target.bit 5, 7, 128)}.to raise_error StandardError
      expect{(target.bit 6, 7, 128)}.to raise_error StandardError
      expect{(target.bit 7, 7, 128)}.to raise_error StandardError
      
      expect{target.bit 0, 1,   2}.to raise_error StandardError
      expect{target.bit 0, 2,   4}.to raise_error StandardError
      expect{target.bit 0, 3,   8}.to raise_error StandardError
      expect{target.bit 0, 4,  16}.to raise_error StandardError
      expect{target.bit 0, 5,  32}.to raise_error StandardError
      expect{target.bit 0, 6,  64}.to raise_error StandardError
      expect{target.bit 0, 7, 128}.to raise_error StandardError
      expect{target.bit 0, 8, 256}.to raise_error StandardError
    end
  end
end

# 
# 例外について参考メモ
#  http://qiita.com/kasei-san/items/75ad2bb384fdb7e05941
#
# StandardError は、Exception のサブクラス
# Exceptionは、システム関係の例外も含む
# アプリケーションレベルの例外であれば、
# StandardError を使うべきという思想らしい
# そのため、rescue で、型指定をしない場合は、
# StandardError を継承している例外のみ catch する
# ---
# begin
#   raise "エラーメッセージ" # catch する
#   raise Exception.new("エラーメッセージ") # catch しない
# rescue => e
#   p e.message
# end
#

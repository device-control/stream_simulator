# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'sequence_command/sequence_command_error'
require 'log'

describe 'SequenceCommandError' do
  # 運用ログは黙らせておく
  log = Log.instance
  log.disabled
  
  before do
  end
  
  context 'initialize' do
    it '正しく生成できること' do
      e = nil
      expect{ e = SequenceCommandError.new("message", "pos", ["0","1"]) }.not_to raise_error
      expect(e.message).to eq "message"
      expect(e.position).to eq "pos"
      expect(e.detail).to eq ["0","1"]
    end
    it '入力パラメータ異常が検出できること' do
      expect{ SequenceCommandError.new("message") }.to raise_error StandardError
      expect{ SequenceCommandError.new("message", "pos") }.to raise_error StandardError
      expect{ SequenceCommandError.new("message", nil, ["0","1"]) }.to raise_error StandardError
    end
  end

end

# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'log'
require 'stream_data/stream_data'

describe 'StreamData' do
  log = Log.instance
  log.disabled

  before do
    
  end
  
  context '生成' do
    it 'サンプルのstream_data設定が正しく生成されることを確認' do
      expect{ StreamData.create '../samples/01_both_tcp' }.not_to raise_error
    end
  end

end

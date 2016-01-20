# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream_data'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream_runner'))

require 'test_data'
require 'log'

require 'pry'

describe 'TestData' do
  before do
    log = Log.instance
    log.disabled
  end
  
  context '生成' do
    it 'サンプルのtcp_clinet設定が正しく生成されることを確認' do
      expect{ TestData.new '../samples/01_both_tcp/tcp_client/test_data' }.not_to raise_error
    end
    it 'サンプルのtcp_clinet設定が正しく生成されることを確認' do
      expect{ TestData.new '../samples/01_both_tcp/tcp_server/test_data' }.not_to raise_error
    end
  end

end

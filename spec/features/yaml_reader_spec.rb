# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))

require 'yaml_reader'
require 'log'

require 'pry'

describe 'TestData' do
  before do
    log = Log.instance
    log.disabled
  end
  
  context '読み込み' do
    it 'サンプルのtcp_server設定が正しく読み込まれることを確認' do
      expect{ YamlReader.get_yamls '../settings/tcp_server/test_data' }.not_to raise_error
    end
    it 'サンプルのtcp_clinet設定が正しく生成されることを確認' do
      expect{ YamlReader.get_yamls '../settings/tcp_client/test_data' }.not_to raise_error
    end
  end

end

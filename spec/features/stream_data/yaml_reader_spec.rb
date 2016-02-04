# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'stream_data/yaml_reader'
require 'log'

describe 'YamlReader' do
  log = Log.instance
  log.disabled

  let(:test_class) { Struct.new(:test) { include YamlReader } }
  let(:target) { test_class.new }
  
  before do
  end
  
  context '読み込み' do
    it 'サンプルのyamlファイルが正しく読み込まれることを確認' do
      yamls = nil
      
      expect{ yamls = target.get_yamls '../samples/01_both_tcp/stream_data/settings' }.not_to raise_error
      expect(yamls.size).to eq 2 # 件数
      files = [
        '../samples/01_both_tcp/stream_data/settings/tcp_client_setting.yml',
        '../samples/01_both_tcp/stream_data/settings/tcp_server_setting.yml',
      ]
      # yaml存在確認
      yamls.each.with_index(0) do |info,index|
        expect(info[:file]).to eq files[index]
        expect(info[:body]).not_to eq nil
      end
    end
  end
end

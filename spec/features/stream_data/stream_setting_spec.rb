# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'stream_data/yaml_reader'
require 'stream_data/stream_setting'
require 'log'
require 'pry'

describe 'StreamSetting' do
  # 運用ログは黙らせておく
  log = Log.instance
  log.disabled
  yaml_reader_class = Struct.new(:test) { include YamlReader}
  yaml_reader = yaml_reader_class.new
  path = '../samples/01_both_tcp/stream_data/settings'
  yamls = yaml_reader.get_yamls path
  stream_setting_yamls = yaml_reader.yamls_by_name yamls, 'stream_setting'

  before do
  end
  
  context 'ストリーム情報生成' do
    it 'ymlファイルから:TCP_SERVERストリーム情報が生成できることを確認' do
      stream_setting = nil
      name = "tcp_server_setting"
      expect{ stream_setting = StreamSetting.create name, stream_setting_yamls[name] }.not_to raise_error
      expect(stream_setting.name).to eq name
      expect(stream_setting.file).to eq path + "/#{name}.yml"
      expect(stream_setting.parameters[:type]).to eq :TCP_SERVER
      expect(stream_setting.parameters[:name]).to eq "TCPサーバ"
      expect(stream_setting.parameters[:ip]).to eq "127.0.0.1"
      expect(stream_setting.parameters[:port]).to eq 50000
    end
    it 'ymlファイルから:TCP_CLIENTストリーム情報が生成できることを確認' do
      stream_setting = nil
      name = "tcp_client_setting"
      expect{ stream_setting = StreamSetting.create name, stream_setting_yamls[name] }.not_to raise_error
      expect(stream_setting.name).to eq name
      expect(stream_setting.file).to eq path + "/#{name}.yml"
      expect(stream_setting.parameters[:type]).to eq :TCP_CLIENT
      expect(stream_setting.parameters[:name]).to eq "TCPクライアント"
      expect(stream_setting.parameters[:ip]).to eq "127.0.0.1"
      expect(stream_setting.parameters[:port]).to eq 50000
    end
  end
end

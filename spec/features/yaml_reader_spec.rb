# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream_data'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream_runner'))

require 'yaml_reader'
require 'log'

describe 'YamlReader' do
  before do
    log = Log.instance
    log.disabled
  end
  
  context '読み込み' do
    it 'サンプルのtcp_server設定が正しく読み込まれることを確認' do
      yamls = nil
      expect{ yamls = YamlReader.get_yamls '../samples/01_both_tcp/tcp_server/test_data' }.not_to raise_error
      expect(yamls.size).to eq 6 # 件数
      files = [
        '../samples/01_both_tcp/tcp_server/test_data/message_data/command_data.yml',
        '../samples/01_both_tcp/tcp_server/test_data/message_data/response_data.yml',
        '../samples/01_both_tcp/tcp_server/test_data/message_format/0x10_command.yml',
        '../samples/01_both_tcp/tcp_server/test_data/message_format/0x10_response.yml',
        '../samples/01_both_tcp/tcp_server/test_data/scenario_data/ScenarioData.yml',
        '../samples/01_both_tcp/tcp_server/test_data/settings/stream_setting.yml',
      ]
      # yaml存在確認
      yamls.each.with_index(0) do |info,index|
        expect(info[:file]).to eq files[index]
        expect(info[:yaml]).not_to eq nil
      end
    end
    it 'サンプルのtcp_clinet設定が正しく生成されることを確認' do
      yamls = nil
      expect{ yamls = YamlReader.get_yamls '../samples/01_both_tcp/tcp_client/test_data' }.not_to raise_error
      expect(yamls.size).to eq 6 # 件数
      files = [
        '../samples/01_both_tcp/tcp_client/test_data/message_data/command_data.yml',
        '../samples/01_both_tcp/tcp_client/test_data/message_data/response_data.yml',
        '../samples/01_both_tcp/tcp_client/test_data/message_format/0x10_command.yml',
        '../samples/01_both_tcp/tcp_client/test_data/message_format/0x10_response.yml',
        '../samples/01_both_tcp/tcp_client/test_data/scenario_data/ScenarioData.yml',
        '../samples/01_both_tcp/tcp_client/test_data/settings/stream_setting.yml',
      ]
      # yaml存在確認
      yamls.each.with_index(0) do |info,index|
        expect(info[:file]).to eq files[index]
        expect(info[:yaml]).not_to eq nil
      end
    end
  end

end

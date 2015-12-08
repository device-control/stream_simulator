# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))

require 'stream_setting'
require 'log'

require 'pry'

describe 'StreamSetting' do
  before do
    # 運用ログは黙らせておく
    log = Log.instance
    log.disabled
  end
  
  context 'ストリーム情報生成' do
    it 'ymlファイルから:TCP_SERVERストリーム情報が生成できることを確認' do
      map = nil
      expect{ map = StreamSetting.load '../settings/tcp_server/stream_setting.yml' }.not_to raise_error
      expect(map[:type]).to eq :TCP_SERVER
      expect(map[:name]).to eq "TCPサーバ"
      expect(map[:ip]).to eq "127.0.0.1"
      expect(map[:port]).to eq 50000
    end
    it 'ymlファイルから:TCP_CLIENTストリーム情報が生成できることを確認' do
      map = nil
      expect{ map = StreamSetting.load '../settings/tcp_client/stream_setting.yml' }.not_to raise_error
      expect(map[:type]).to eq :TCP_CLIENT
      expect(map[:name]).to eq "TCPクライアント"
      expect(map[:ip]).to eq "127.0.0.1"
      expect(map[:port]).to eq 50000
    end
  end
end

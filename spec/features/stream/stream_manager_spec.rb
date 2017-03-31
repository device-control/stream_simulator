# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'stream/stream_manager'
require 'log'

describe 'StreamManager' do
  before do
    # 運用ログは黙らせておく
    log = Log.instance
    log.disabled
  end
  
  context 'ストリーム生成' do
    it 'tcp_serverが正しく生成されること確認' do
      map = Hash.new
      map[:type] = :TCP_SERVER
      map[:name] = "tcp_server"
      map[:ip] = "127.0.0.1"
      map[:port] = 7080
      map[:timeout] = 5
      expect{ StreamManager.create map }.not_to raise_error
    end
    it 'tcp_clientが正しく生成されること確認' do
      map = Hash.new
      map[:type] = :TCP_CLIENT
      map[:name] = "tcp_client"
      map[:ip] = "127.0.0.1"
      map[:port] = 7080
      map[:timeout] = 5
      expect{ StreamManager.create map }.not_to raise_error
    end
    it 'serialが正しく生成されること確認' do
      map = Hash.new
      map[:type] = :SERIAL
      map[:name] = "serial"
      map[:port] = "COM3"
      map[:baud_rate] = 115200
      map[:data_bits] = 8
      map[:stop_bits] = 1
      map[:parity] = "NONE"
      expect{ StreamManager.create map }.not_to raise_error
    end
  end

end

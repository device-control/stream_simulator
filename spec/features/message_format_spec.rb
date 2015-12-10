# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))

require 'message_format'
require 'log'
require 'yaml_reader'

require 'pry'

describe 'MessageFormat' do
  before do
    log = Log.instance
    log.disabled
    @yamls = YamlReader.get_yamls '../settings/tcp_server/test_data/message_format'
  end
  
  context '生成' do
    it '正しく生成されることを確認' do
      yaml = @yamls[0][:yaml]
      format= MessageFormat.new yaml['contents']
      expect(format).not_to eq nil
    end
    it 'デフォルト値がエンコードできることを確認' do
      yaml = @yamls[0][:yaml]
      format= MessageFormat.new yaml['contents']
      actual = ['1001123412345678FEDCBA98'].pack("H*") # 予想
      result = format.encode()
      expect(result).to eq actual # デフォルトエンコード確認
    end
    
    it 'エンコード／デコードできることを確認' do
      yaml = @yamls[0][:yaml]
      format= MessageFormat.new yaml['contents']
      input_data = Array.new
      input_data << { 'name' => 'function_code',             'value' => 0x10 }
      input_data << { 'name' => 'kind',                      'value' => 0x01 }
      input_data << { 'name' => 'field_length',              'value' => 0x1234 }
      input_data << { 'name' => 'fixed_ip_address_setting',  'value' => 0x12345678 }
      input_data << { 'name' => 'sub_net_mask',              'value' => 0xFEDCBA98 }
      actual = ['1001123412345678FEDCBA98'].pack("H*") # 予想
      result = format.encode(input_data)
      expect(result).to eq actual # エンコード確認
      output_data = format.decode(actual)
      expect(output_data).to eq input_data # デコード確認
    end
  end
end

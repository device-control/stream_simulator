# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream_data'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src/stream_runner'))

require 'message_format'
require 'log'
require 'yaml_reader'

require 'pry'

describe 'MessageFormat' do
  before do
    log = Log.instance
    log.disabled
    @yamls = YamlReader.get_yamls '../samples/01_both_tcp/tcp_server/test_data/message_format'
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
      actual = '1001123412345678FEDCBA98' # 予想
      result = format.encode()
      expect(result).to eq actual # デフォルトエンコード確認
    end
    
    it 'エンコード／デコードできることを確認 encode/decode' do
      yaml = @yamls[0][:yaml]
      format= MessageFormat.new yaml['contents']
      input_data = Array.new
      input_data << { 'name' => 'function_code',             'value' => 0x10 }
      input_data << { 'name' => 'kind',                      'value' => 0x01 }
      input_data << { 'name' => 'field_length',              'value' => 0x1234 }
      input_data << { 'name' => 'fixed_ip_address_setting',  'value' => 0x12345678 }
      input_data << { 'name' => 'sub_net_mask',              'value' => 0xFEDCBA98 }
      actual = '1001123412345678FEDCBA98' # 予想
      result = format.encode(input_data)
      expect(result).to eq actual # エンコード確認
      output_data = format.decode(actual)
      expect(output_data).to eq input_data # デコード確認
    end
    
    it '対象電文の有無判断の確認 target?' do
      yaml = @yamls[0][:yaml]
      format= MessageFormat.new yaml['contents']
      message = '1001123412345678FEDCBA98' # メッセージ(バイナリテキスト）
      expect(format.target?(message)).to eq true
      message = '0001123412345678FEDCBA98' # メッセージ(バイナリテキスト）
      expect(format.target?(message)).to eq false
    end
    
    it 'プライマリキーの一致確認 check_primary_key' do
      yaml = @yamls[0][:yaml]
      format= MessageFormat.new yaml['contents']
      message = '1001123412345678FEDCBA98' # メッセージ(バイナリテキスト）
      expect(format.check_primary_key(message)).to eq true
      message = '0001123412345678FEDCBA98' # メッセージ(バイナリテキスト）
      expect(format.check_primary_key(message)).to eq false
    end

    it 'default_value値とtypeで指定した型サイズの確認 message_format_contents' do
      yaml = @yamls[0][:yaml]
      format= MessageFormat.new yaml['contents']
      contents = Marshal.load Marshal.dump(yaml['contents'])
      expect(format.message_format_contents?(contents)).to eq true
      
      # int8でdefault_value値がサイズオーバー
      contents = Marshal.load Marshal.dump(yaml['contents'])
      contents["format"][0]["default_value"] = 0x111
      expect{format.message_format_contents?(contents)}.to raise_error RuntimeError
      
      # int32でdefault_value値がサイズオーバー
      contents = Marshal.load Marshal.dump(yaml['contents'])
      contents["format"][4]["default_value"] = 0xfffffffff
      expect{format.message_format_contents?(contents)}.to raise_error RuntimeError
      
    end
      
  end
end

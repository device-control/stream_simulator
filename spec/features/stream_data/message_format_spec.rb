# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'stream_data/yaml_reader'
require 'stream_data/message_format'
require 'stream_data/message_entity'
require 'log'

require 'pry'

describe 'MessageFormat' do
  log = Log.instance
  log.disabled
  dummy_class = Struct.new(:test) { include YamlReader}
  yaml_reader = dummy_class.new
  yamls = yaml_reader.get_yamls '../samples/01_both_tcp/stream_data/messages'
  message_formats = yaml_reader.yamls_by_name yamls, 'message_format'
  message_structs = yaml_reader.yamls_by_name yamls, 'message_struct'
  
  before do
  end
  
  context '生成' do
    it '正しく生成されることを確認' do
      message_formats.each do |name,yaml|
        format= MessageFormat.create name, yaml, message_structs
        expect(format).not_to eq nil
      end
    end
    it 'エンコードできることを確認' do
      # 予想
      expect_hex_string = '010100020000000334'
      name = 'command_format' # テスト対象はcommand_formatのみ
      yaml = message_formats[name]
      format= MessageFormat.create name, yaml, message_structs
      result = format.encode({})
      expect(result).to eq expect_hex_string
    end
    
    it 'デコードできることを確認 encode/decode' do
      hex_string = 'FFEEDDDDCCCCCCCC42'
      expect_values = {
        'id' => 0xff,
        'member1_int8' => 0xee,
        'member2_int16' => 0xdddd,
        'member3_int32' => 0xcccccccc,
        'member4_char' => "B",
      }
      name = 'command_format' # テスト対象はcommand_formatのみ
      yaml = message_formats[name]
      format= MessageFormat.create name, yaml, message_structs
      values = format.decode(hex_string)
      expect(values).to eq expect_values
    end

    it 'プライマリキーの一致確認 primary_keys_match?' do
      name = 'command_format' # テスト対象はcommand_formatのみ
      yaml = message_formats[name]
      format= MessageFormat.create name, yaml, message_structs
      
      values = { "id" => 0x01 }
      expect(format.primary_keys_match? values).to eq true
      values = { "id" => 0x02 }
      expect(format.primary_keys_match? values).to eq false
    end

    it '対象電文の有無判断の確認 target?' do
            name = 'command_format' # テスト対象はcommand_formatのみ
      yaml = message_formats[name]
      format= MessageFormat.create name, yaml, message_structs
      
      values = { "id" => 0x01 }
      expect(format.target? values).to eq true
      values = { "id" => 0x02 }
      expect(format.target? values).to eq false
    end
    
  end
end

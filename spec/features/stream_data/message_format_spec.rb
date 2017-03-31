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
      expected_member_list = { "command_format" =>
                               ["id", "member1_int8", "member2_int16", "member3_int32", "member4_char"],
                               
                               "response_format" =>
                               ["id", "member1_int8", "member2_int16", "member3_int32", "member4_char"],

                               "struct_sample_format" =>
                               ["id",
                                "member1_int8",
                                "member2_int16",
                                "member3_int32",
                                "member4_char",
                                "member5_struct.member1_int8",
                                "member5_struct.member2_int16",
                                "member5_struct.member3_int32",
                                "member5_struct.member4_char",
                                "member5_struct.member5_sub_struct.member1_int8",
                                "member5_struct.member5_sub_struct.member2_int16",
                                "member5_struct.member5_sub_struct.member3_int32",
                                "member5_struct.member5_sub_struct.member4_char",
                                "member5_struct.member6_int8[0]",
                                "member5_struct.member6_int8[1]",
                                "member5_struct.member6_int8[2]",
                                "member5_struct.member7_int16[0]",
                                "member5_struct.member7_int16[1]",
                                "member5_struct.member7_int16[2]",
                                "member5_struct.member8_int32[0]",
                                "member5_struct.member8_int32[1]",
                                "member5_struct.member8_int32[2]",
                                "member5_struct.member9_char",
                                "member5_struct.member10_sub_struct[0].member1_int8",
                                "member5_struct.member10_sub_struct[0].member2_int16",
                                "member5_struct.member10_sub_struct[0].member3_int32",
                                "member5_struct.member10_sub_struct[0].member4_char",
                                "member5_struct.member10_sub_struct[1].member1_int8",
                                "member5_struct.member10_sub_struct[1].member2_int16",
                                "member5_struct.member10_sub_struct[1].member3_int32",
                                "member5_struct.member10_sub_struct[1].member4_char",
                                "member5_struct.member10_sub_struct[2].member1_int8",
                                "member5_struct.member10_sub_struct[2].member2_int16",
                                "member5_struct.member10_sub_struct[2].member3_int32",
                                "member5_struct.member10_sub_struct[2].member4_char",
                                "member6_int8[0]",
                                "member6_int8[1]",
                                "member6_int8[2]",
                                "member7_int16[0]",
                                "member7_int16[1]",
                                "member7_int16[2]",
                                "member8_int32[0]",
                                "member8_int32[1]",
                                "member8_int32[2]",
                                "member9_char",
                                "member10_struct[0].member1_int8",
                                "member10_struct[0].member2_int16",
                                "member10_struct[0].member3_int32",
                                "member10_struct[0].member4_char",
                                "member10_struct[0].member5_sub_struct.member1_int8",
                                "member10_struct[0].member5_sub_struct.member2_int16",
                                "member10_struct[0].member5_sub_struct.member3_int32",
                                "member10_struct[0].member5_sub_struct.member4_char",
                                "member10_struct[0].member6_int8[0]",
                                "member10_struct[0].member6_int8[1]",
                                "member10_struct[0].member6_int8[2]",
                                "member10_struct[0].member7_int16[0]",
                                "member10_struct[0].member7_int16[1]",
                                "member10_struct[0].member7_int16[2]",
                                "member10_struct[0].member8_int32[0]",
                                "member10_struct[0].member8_int32[1]",
                                "member10_struct[0].member8_int32[2]",
                                "member10_struct[0].member9_char",
                                "member10_struct[0].member10_sub_struct[0].member1_int8",
                                "member10_struct[0].member10_sub_struct[0].member2_int16",
                                "member10_struct[0].member10_sub_struct[0].member3_int32",
                                "member10_struct[0].member10_sub_struct[0].member4_char",
                                "member10_struct[0].member10_sub_struct[1].member1_int8",
                                "member10_struct[0].member10_sub_struct[1].member2_int16",
                                "member10_struct[0].member10_sub_struct[1].member3_int32",
                                "member10_struct[0].member10_sub_struct[1].member4_char",
                                "member10_struct[0].member10_sub_struct[2].member1_int8",
                                "member10_struct[0].member10_sub_struct[2].member2_int16",
                                "member10_struct[0].member10_sub_struct[2].member3_int32",
                                "member10_struct[0].member10_sub_struct[2].member4_char",
                                "member10_struct[1].member1_int8",
                                "member10_struct[1].member2_int16",
                                "member10_struct[1].member3_int32",
                                "member10_struct[1].member4_char",
                                "member10_struct[1].member5_sub_struct.member1_int8",
                                "member10_struct[1].member5_sub_struct.member2_int16",
                                "member10_struct[1].member5_sub_struct.member3_int32",
                                "member10_struct[1].member5_sub_struct.member4_char",
                                "member10_struct[1].member6_int8[0]",
                                "member10_struct[1].member6_int8[1]",
                                "member10_struct[1].member6_int8[2]",
                                "member10_struct[1].member7_int16[0]",
                                "member10_struct[1].member7_int16[1]",
                                "member10_struct[1].member7_int16[2]",
                                "member10_struct[1].member8_int32[0]",
                                "member10_struct[1].member8_int32[1]",
                                "member10_struct[1].member8_int32[2]",
                                "member10_struct[1].member9_char",
                                "member10_struct[1].member10_sub_struct[0].member1_int8",
                                "member10_struct[1].member10_sub_struct[0].member2_int16",
                                "member10_struct[1].member10_sub_struct[0].member3_int32",
                                "member10_struct[1].member10_sub_struct[0].member4_char",
                                "member10_struct[1].member10_sub_struct[1].member1_int8",
                                "member10_struct[1].member10_sub_struct[1].member2_int16",
                                "member10_struct[1].member10_sub_struct[1].member3_int32",
                                "member10_struct[1].member10_sub_struct[1].member4_char",
                                "member10_struct[1].member10_sub_struct[2].member1_int8",
                                "member10_struct[1].member10_sub_struct[2].member2_int16",
                                "member10_struct[1].member10_sub_struct[2].member3_int32",
                                "member10_struct[1].member10_sub_struct[2].member4_char",
                                "member10_struct[2].member1_int8",
                                "member10_struct[2].member2_int16",
                                "member10_struct[2].member3_int32",
                                "member10_struct[2].member4_char",
                                "member10_struct[2].member5_sub_struct.member1_int8",
                                "member10_struct[2].member5_sub_struct.member2_int16",
                                "member10_struct[2].member5_sub_struct.member3_int32",
                                "member10_struct[2].member5_sub_struct.member4_char",
                                "member10_struct[2].member6_int8[0]",
                                "member10_struct[2].member6_int8[1]",
                                "member10_struct[2].member6_int8[2]",
                                "member10_struct[2].member7_int16[0]",
                                "member10_struct[2].member7_int16[1]",
                                "member10_struct[2].member7_int16[2]",
                                "member10_struct[2].member8_int32[0]",
                                "member10_struct[2].member8_int32[1]",
                                "member10_struct[2].member8_int32[2]",
                                "member10_struct[2].member9_char",
                                "member10_struct[2].member10_sub_struct[0].member1_int8",
                                "member10_struct[2].member10_sub_struct[0].member2_int16",
                                "member10_struct[2].member10_sub_struct[0].member3_int32",
                                "member10_struct[2].member10_sub_struct[0].member4_char",
                                "member10_struct[2].member10_sub_struct[1].member1_int8",
                                "member10_struct[2].member10_sub_struct[1].member2_int16",
                                "member10_struct[2].member10_sub_struct[1].member3_int32",
                                "member10_struct[2].member10_sub_struct[1].member4_char",
                                "member10_struct[2].member10_sub_struct[2].member1_int8",
                                "member10_struct[2].member10_sub_struct[2].member2_int16",
                                "member10_struct[2].member10_sub_struct[2].member3_int32",
                                "member10_struct[2].member10_sub_struct[2].member4_char"],
                             }
      expected_member_total_size = { "command_format" => 9,
                                     "response_format" => 9,
                                     "struct_sample_format" => 289
                                   }
      message_formats.each.with_index(0) do |(name,yaml),index|
        format= MessageFormat.create name, yaml, message_structs
        expect(format).not_to eq nil
       expect(format.member_list).to eq expected_member_list[format.name] # member_list が想定通りか確認
       expect(format.member_total_size).to eq expected_member_total_size[format.name] # member_total_size が想定通りか確認
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

# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'hashie'
require 'stream_data/yaml_reader'
require 'stream_data/message_format'
require 'stream_data/message_entity'
require 'log'
require 'benchmark'

require 'pry'

def _dbg_print(name,value)
  out = Array.new
  out << "\"#{name}\" => {"
  if value.default_value.class == String
    out << " \"default_value\" => \"#{value.default_value}\","
  else
    out << " \"default_value\" => #{value.default_value},"
  end
  out << " \"name\" => \"#{value.name}\","
  out << " \"name_jp\" => \"#{value.name_jp}\","
  out << " \"offset\" => #{value.offset},"
  out << " \"size\" => #{value.size},"
  out << " \"type\" => :#{value.type},"
  out << "},"
  return out
end


def dbg_print_members(format)
  members = Hashie::Mash.new format.members
  out = Array.new
  format.member_list.each do |name|
    value = eval "members.#{name}"
    out << _dbg_print(name,value)
  end
  File.write "#{format.name}.txt", out.join("\n")
end

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

      expected_values = { "command_format" =>
                          {"id"=>1, "member1_int8"=>1, "member2_int16"=>2, "member3_int32"=>3, "member4_char"=>"4"},
                          "response_format" =>
                          {"id"=>129, "member1_int8"=>255, "member2_int16"=>65535, "member3_int32"=>4294967295, "member4_char"=>"Z"},
                          "struct_sample_format" =>
                          {"id"=>255,
                           "member1_int8"=>0,
                           "member2_int16"=>0,
                           "member3_int32"=>0,
                           "member4_char"=>"",
                           "member5_struct.member1_int8"=>0,
                           "member5_struct.member2_int16"=>0,
                           "member5_struct.member3_int32"=>0,
                           "member5_struct.member4_char"=>"",
                           "member5_struct.member5_sub_struct.member1_int8"=>0,
                           "member5_struct.member5_sub_struct.member2_int16"=>0,
                           "member5_struct.member5_sub_struct.member3_int32"=>0,
                           "member5_struct.member5_sub_struct.member4_char"=>"",
                           "member5_struct.member6_int8[0]"=>0,
                           "member5_struct.member6_int8[1]"=>0,
                           "member5_struct.member6_int8[2]"=>0,
                           "member5_struct.member7_int16[0]"=>0,
                           "member5_struct.member7_int16[1]"=>0,
                           "member5_struct.member7_int16[2]"=>0,
                           "member5_struct.member8_int32[0]"=>0,
                           "member5_struct.member8_int32[1]"=>0,
                           "member5_struct.member8_int32[2]"=>0,
                           "member5_struct.member9_char"=>"",
                           "member5_struct.member10_sub_struct[0].member1_int8"=>0,
                           "member5_struct.member10_sub_struct[0].member2_int16"=>0,
                           "member5_struct.member10_sub_struct[0].member3_int32"=>0,
                           "member5_struct.member10_sub_struct[0].member4_char"=>"",
                           "member5_struct.member10_sub_struct[1].member1_int8"=>0,
                           "member5_struct.member10_sub_struct[1].member2_int16"=>0,
                           "member5_struct.member10_sub_struct[1].member3_int32"=>0,
                           "member5_struct.member10_sub_struct[1].member4_char"=>"",
                           "member5_struct.member10_sub_struct[2].member1_int8"=>0,
                           "member5_struct.member10_sub_struct[2].member2_int16"=>0,
                           "member5_struct.member10_sub_struct[2].member3_int32"=>0,
                           "member5_struct.member10_sub_struct[2].member4_char"=>"",
                           "member6_int8[0]"=>0,
                           "member6_int8[1]"=>0,
                           "member6_int8[2]"=>0,
                           "member7_int16[0]"=>0,
                           "member7_int16[1]"=>0,
                           "member7_int16[2]"=>0,
                           "member8_int32[0]"=>0,
                           "member8_int32[1]"=>0,
                           "member8_int32[2]"=>0,
                           "member9_char"=>"",
                           "member10_struct[0].member1_int8"=>0,
                           "member10_struct[0].member2_int16"=>0,
                           "member10_struct[0].member3_int32"=>0,
                           "member10_struct[0].member4_char"=>"",
                           "member10_struct[0].member5_sub_struct.member1_int8"=>0,
                           "member10_struct[0].member5_sub_struct.member2_int16"=>0,
                           "member10_struct[0].member5_sub_struct.member3_int32"=>0,
                           "member10_struct[0].member5_sub_struct.member4_char"=>"",
                           "member10_struct[0].member6_int8[0]"=>0,
                           "member10_struct[0].member6_int8[1]"=>0,
                           "member10_struct[0].member6_int8[2]"=>0,
                           "member10_struct[0].member7_int16[0]"=>0,
                           "member10_struct[0].member7_int16[1]"=>0,
                           "member10_struct[0].member7_int16[2]"=>0,
                           "member10_struct[0].member8_int32[0]"=>0,
                           "member10_struct[0].member8_int32[1]"=>0,
                           "member10_struct[0].member8_int32[2]"=>0,
                           "member10_struct[0].member9_char"=>"",
                           "member10_struct[0].member10_sub_struct[0].member1_int8"=>0,
                           "member10_struct[0].member10_sub_struct[0].member2_int16"=>0,
                           "member10_struct[0].member10_sub_struct[0].member3_int32"=>0,
                           "member10_struct[0].member10_sub_struct[0].member4_char"=>"",
                           "member10_struct[0].member10_sub_struct[1].member1_int8"=>0,
                           "member10_struct[0].member10_sub_struct[1].member2_int16"=>0,
                           "member10_struct[0].member10_sub_struct[1].member3_int32"=>0,
                           "member10_struct[0].member10_sub_struct[1].member4_char"=>"",
                           "member10_struct[0].member10_sub_struct[2].member1_int8"=>0,
                           "member10_struct[0].member10_sub_struct[2].member2_int16"=>0,
                           "member10_struct[0].member10_sub_struct[2].member3_int32"=>0,
                           "member10_struct[0].member10_sub_struct[2].member4_char"=>"",
                           "member10_struct[1].member1_int8"=>0,
                           "member10_struct[1].member2_int16"=>0,
                           "member10_struct[1].member3_int32"=>0,
                           "member10_struct[1].member4_char"=>"",
                           "member10_struct[1].member5_sub_struct.member1_int8"=>0,
                           "member10_struct[1].member5_sub_struct.member2_int16"=>0,
                           "member10_struct[1].member5_sub_struct.member3_int32"=>0,
                           "member10_struct[1].member5_sub_struct.member4_char"=>"",
                           "member10_struct[1].member6_int8[0]"=>0,
                           "member10_struct[1].member6_int8[1]"=>0,
                           "member10_struct[1].member6_int8[2]"=>0,
                           "member10_struct[1].member7_int16[0]"=>0,
                           "member10_struct[1].member7_int16[1]"=>0,
                           "member10_struct[1].member7_int16[2]"=>0,
                           "member10_struct[1].member8_int32[0]"=>0,
                           "member10_struct[1].member8_int32[1]"=>0,
                           "member10_struct[1].member8_int32[2]"=>0,
                           "member10_struct[1].member9_char"=>"",
                           "member10_struct[1].member10_sub_struct[0].member1_int8"=>0,
                           "member10_struct[1].member10_sub_struct[0].member2_int16"=>0,
                           "member10_struct[1].member10_sub_struct[0].member3_int32"=>0,
                           "member10_struct[1].member10_sub_struct[0].member4_char"=>"",
                           "member10_struct[1].member10_sub_struct[1].member1_int8"=>0,
                           "member10_struct[1].member10_sub_struct[1].member2_int16"=>0,
                           "member10_struct[1].member10_sub_struct[1].member3_int32"=>0,
                           "member10_struct[1].member10_sub_struct[1].member4_char"=>"",
                           "member10_struct[1].member10_sub_struct[2].member1_int8"=>0,
                           "member10_struct[1].member10_sub_struct[2].member2_int16"=>0,
                           "member10_struct[1].member10_sub_struct[2].member3_int32"=>0,
                           "member10_struct[1].member10_sub_struct[2].member4_char"=>"",
                           "member10_struct[2].member1_int8"=>0,
                           "member10_struct[2].member2_int16"=>0,
                           "member10_struct[2].member3_int32"=>0,
                           "member10_struct[2].member4_char"=>"",
                           "member10_struct[2].member5_sub_struct.member1_int8"=>0,
                           "member10_struct[2].member5_sub_struct.member2_int16"=>0,
                           "member10_struct[2].member5_sub_struct.member3_int32"=>0,
                           "member10_struct[2].member5_sub_struct.member4_char"=>"",
                           "member10_struct[2].member6_int8[0]"=>0,
                           "member10_struct[2].member6_int8[1]"=>0,
                           "member10_struct[2].member6_int8[2]"=>0,
                           "member10_struct[2].member7_int16[0]"=>0,
                           "member10_struct[2].member7_int16[1]"=>0,
                           "member10_struct[2].member7_int16[2]"=>0,
                           "member10_struct[2].member8_int32[0]"=>0,
                           "member10_struct[2].member8_int32[1]"=>0,
                           "member10_struct[2].member8_int32[2]"=>0,
                           "member10_struct[2].member9_char"=>"",
                           "member10_struct[2].member10_sub_struct[0].member1_int8"=>0,
                           "member10_struct[2].member10_sub_struct[0].member2_int16"=>0,
                           "member10_struct[2].member10_sub_struct[0].member3_int32"=>0,
                           "member10_struct[2].member10_sub_struct[0].member4_char"=>"",
                           "member10_struct[2].member10_sub_struct[1].member1_int8"=>0,
                           "member10_struct[2].member10_sub_struct[1].member2_int16"=>0,
                           "member10_struct[2].member10_sub_struct[1].member3_int32"=>0,
                           "member10_struct[2].member10_sub_struct[1].member4_char"=>"",
                           "member10_struct[2].member10_sub_struct[2].member1_int8"=>0,
                           "member10_struct[2].member10_sub_struct[2].member2_int16"=>0,
                           "member10_struct[2].member10_sub_struct[2].member3_int32"=>0,
                           "member10_struct[2].member10_sub_struct[2].member4_char"=>""}
                        }

      expected_primary_keys = { "command_format" =>
                                {"id"=>1},
                                "response_format" =>
                                {"id"=>129},
                                "struct_sample_format" =>
                                {"id"=>255},
                              }

      expected_member_data = { "command_format" => {
                                 "id" => {
                                   "default_value" => 0,
                                   "name" => "id",
                                   "name_jp" => "ID",
                                   "offset" => 0,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 1,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 2,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 4,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 8,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                               },
                               
                               "response_format" => {
                                 "id" => {
                                   "default_value" => 0,
                                   "name" => "id",
                                   "name_jp" => "ID",
                                   "offset" => 0,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 1,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 2,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 4,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 8,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                               },
                               
                               "struct_sample_format" => {
                                 "id" => {
                                   "default_value" => 0,
                                   "name" => "id",
                                   "name_jp" => "ID",
                                   "offset" => 0,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 1,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 2,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 4,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 8,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member5_struct.member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 9,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member5_struct.member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 10,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member5_struct.member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 12,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member5_struct.member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 16,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member5_struct.member5_sub_struct.member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 17,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member5_struct.member5_sub_struct.member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 18,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member5_struct.member5_sub_struct.member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 20,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member5_struct.member5_sub_struct.member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 24,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member5_struct.member6_int8[0]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 25,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member5_struct.member6_int8[1]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 26,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member5_struct.member6_int8[2]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 27,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member5_struct.member7_int16[0]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 28,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member5_struct.member7_int16[1]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 30,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member5_struct.member7_int16[2]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 32,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member5_struct.member8_int32[0]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 34,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member5_struct.member8_int32[1]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 38,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member5_struct.member8_int32[2]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 42,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member5_struct.member9_char" => {
                                   "default_value" => "",
                                   "name" => "member9_char",
                                   "name_jp" => "member9 CHAR[3]",
                                   "offset" => 46,
                                   "size" => 3,
                                   "type" => :CHAR,
                                 },
                                 "member5_struct.member10_sub_struct[0].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 49,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member5_struct.member10_sub_struct[0].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 50,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member5_struct.member10_sub_struct[0].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 52,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member5_struct.member10_sub_struct[0].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 56,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member5_struct.member10_sub_struct[1].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 57,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member5_struct.member10_sub_struct[1].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 58,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member5_struct.member10_sub_struct[1].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 60,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member5_struct.member10_sub_struct[1].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 64,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member5_struct.member10_sub_struct[2].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 65,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member5_struct.member10_sub_struct[2].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 66,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member5_struct.member10_sub_struct[2].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 68,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member5_struct.member10_sub_struct[2].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 72,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member6_int8[0]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 73,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member6_int8[1]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 74,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member6_int8[2]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 75,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member7_int16[0]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 76,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member7_int16[1]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 78,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member7_int16[2]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 80,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member8_int32[0]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 82,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member8_int32[1]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 86,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member8_int32[2]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 90,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member9_char" => {
                                   "default_value" => "",
                                   "name" => "member9_char",
                                   "name_jp" => "member9 CHAR[3]",
                                   "offset" => 94,
                                   "size" => 3,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[0].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 97,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[0].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 98,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[0].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 100,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[0].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 104,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[0].member5_sub_struct.member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 105,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[0].member5_sub_struct.member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 106,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[0].member5_sub_struct.member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 108,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[0].member5_sub_struct.member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 112,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[0].member6_int8[0]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 113,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[0].member6_int8[1]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 114,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[0].member6_int8[2]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 115,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[0].member7_int16[0]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 116,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[0].member7_int16[1]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 118,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[0].member7_int16[2]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 120,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[0].member8_int32[0]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 122,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[0].member8_int32[1]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 126,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[0].member8_int32[2]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 130,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[0].member9_char" => {
                                   "default_value" => "",
                                   "name" => "member9_char",
                                   "name_jp" => "member9 CHAR[3]",
                                   "offset" => 134,
                                   "size" => 3,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[0].member10_sub_struct[0].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 137,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[0].member10_sub_struct[0].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 138,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[0].member10_sub_struct[0].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 140,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[0].member10_sub_struct[0].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 144,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[0].member10_sub_struct[1].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 145,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[0].member10_sub_struct[1].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 146,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[0].member10_sub_struct[1].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 148,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[0].member10_sub_struct[1].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 152,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[0].member10_sub_struct[2].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 153,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[0].member10_sub_struct[2].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 154,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[0].member10_sub_struct[2].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 156,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[0].member10_sub_struct[2].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 160,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[1].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 161,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[1].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 162,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[1].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 164,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[1].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 168,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[1].member5_sub_struct.member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 169,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[1].member5_sub_struct.member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 170,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[1].member5_sub_struct.member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 172,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[1].member5_sub_struct.member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 176,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[1].member6_int8[0]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 177,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[1].member6_int8[1]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 178,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[1].member6_int8[2]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 179,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[1].member7_int16[0]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 180,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[1].member7_int16[1]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 182,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[1].member7_int16[2]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 184,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[1].member8_int32[0]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 186,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[1].member8_int32[1]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 190,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[1].member8_int32[2]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 194,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[1].member9_char" => {
                                   "default_value" => "",
                                   "name" => "member9_char",
                                   "name_jp" => "member9 CHAR[3]",
                                   "offset" => 198,
                                   "size" => 3,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[1].member10_sub_struct[0].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 201,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[1].member10_sub_struct[0].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 202,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[1].member10_sub_struct[0].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 204,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[1].member10_sub_struct[0].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 208,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[1].member10_sub_struct[1].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 209,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[1].member10_sub_struct[1].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 210,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[1].member10_sub_struct[1].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 212,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[1].member10_sub_struct[1].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 216,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[1].member10_sub_struct[2].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 217,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[1].member10_sub_struct[2].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 218,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[1].member10_sub_struct[2].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 220,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[1].member10_sub_struct[2].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 224,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[2].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 225,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[2].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 226,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[2].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 228,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[2].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 232,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[2].member5_sub_struct.member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 233,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[2].member5_sub_struct.member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 234,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[2].member5_sub_struct.member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 236,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[2].member5_sub_struct.member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 240,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[2].member6_int8[0]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 241,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[2].member6_int8[1]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 242,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[2].member6_int8[2]" => {
                                   "default_value" => 0,
                                   "name" => "member6_int8",
                                   "name_jp" => "member6 INT8[3]",
                                   "offset" => 243,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[2].member7_int16[0]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 244,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[2].member7_int16[1]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 246,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[2].member7_int16[2]" => {
                                   "default_value" => 0,
                                   "name" => "member7_int16",
                                   "name_jp" => "member7 INT16[3]",
                                   "offset" => 248,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[2].member8_int32[0]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 250,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[2].member8_int32[1]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 254,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[2].member8_int32[2]" => {
                                   "default_value" => 0,
                                   "name" => "member8_int32",
                                   "name_jp" => "member8 INT32[3]",
                                   "offset" => 258,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[2].member9_char" => {
                                   "default_value" => "",
                                   "name" => "member9_char",
                                   "name_jp" => "member9 CHAR[3]",
                                   "offset" => 262,
                                   "size" => 3,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[2].member10_sub_struct[0].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 265,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[2].member10_sub_struct[0].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 266,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[2].member10_sub_struct[0].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 268,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[2].member10_sub_struct[0].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 272,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[2].member10_sub_struct[1].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 273,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[2].member10_sub_struct[1].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 274,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[2].member10_sub_struct[1].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 276,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[2].member10_sub_struct[1].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 280,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                                 "member10_struct[2].member10_sub_struct[2].member1_int8" => {
                                   "default_value" => 0,
                                   "name" => "member1_int8",
                                   "name_jp" => "member1 INT8",
                                   "offset" => 281,
                                   "size" => 1,
                                   "type" => :INT8,
                                 },
                                 "member10_struct[2].member10_sub_struct[2].member2_int16" => {
                                   "default_value" => 0,
                                   "name" => "member2_int16",
                                   "name_jp" => "member2 INT16",
                                   "offset" => 282,
                                   "size" => 2,
                                   "type" => :INT16,
                                 },
                                 "member10_struct[2].member10_sub_struct[2].member3_int32" => {
                                   "default_value" => 0,
                                   "name" => "member3_int32",
                                   "name_jp" => "member3 INT32",
                                   "offset" => 284,
                                   "size" => 4,
                                   "type" => :INT32,
                                 },
                                 "member10_struct[2].member10_sub_struct[2].member4_char" => {
                                   "default_value" => "",
                                   "name" => "member4_char",
                                   "name_jp" => "member4 CHAR",
                                   "offset" => 288,
                                   "size" => 1,
                                   "type" => :CHAR,
                                 },
                               },
                             }

      message_formats.each.with_index(0) do |(name,yaml),index|
        format= MessageFormat.create name, yaml, message_structs
        expect(format).not_to eq nil
        expect(format.member_list).to eq expected_member_list[format.name] # member_list が想定通りか確認
        expect(format.member_total_size).to eq expected_member_total_size[format.name] # member_total_size が想定通りか確認
        expect(format.values).to eq expected_values[format.name] # values が想定通りか確認
        expect(format.primary_keys).to eq expected_primary_keys[format.name] # values が想定通りか確認
        hashie_members = Hashie::Mash.new format.members
        format.member_list.each do |member|
          # メンバ要素が存在しているか確認
          res = eval "hashie_members.#{member}"
          expect(res).not_to eq(nil), "#{format.name} not exists member #{member}" # カスタムメッセージは、eq等の引数を括弧で囲まないとnot_be等の関数の引数とが判断できない
          
          # member_dataを確認
          exp_base = expected_member_data[format.name][member]
          a = eval "hashie_members.#{member}.default_value"
          e = exp_base['default_value']
          expect(a).to eq(e), "#{format.name} #{member}.default_value != #{e}"
          
          a = eval "hashie_members.#{member}.name"
          e = exp_base['name']
          expect(a).to eq(e), "#{format.name} #{member}.name != #{e}"
          
          a = eval "hashie_members.#{member}.name_jp"
          e = exp_base['name_jp']
          expect(a).to eq(e), "#{format.name} #{member}.name_jp != #{e}"
          
          a = eval "hashie_members.#{member}.offset"
          e = exp_base['offset']
          expect(a).to eq(e), "#{format.name} #{member}.offset != #{e}"
          
          a = eval "hashie_members.#{member}.size"
          e = exp_base['size']
          expect(a).to eq(e), "#{format.name} #{member}.size != #{e}"
          
          a = eval "hashie_members.#{member}.type"
          e = exp_base['type']
          expect(a).to eq(e), "#{format.name} #{member}.type != #{e}"
          
        end
      end
    end

    it '速度が1秒以下であることを確認' do
      message_formats.each.with_index(0) do |(name,yaml),index|
        next if name != "struct_sample_format"
        format = nil
        bench_result = Benchmark.realtime do
          format= MessageFormat.create name, yaml, message_structs
        end
        expect(bench_result < 1.0 ).to eq true
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

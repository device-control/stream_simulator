# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'execute_function_requestor'
require 'stream_data/extend_hash'

require 'pry'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

if ARGV.length != 1 then
  puts "usage: execute_function [yaml file path]"
  exit
end

# content-type: execute_function
# content-version: 0.1
# contents:
#   name: "外部から関数実行テスト"
#   stream_setting:
#     type: :TCP_CLIENT
#     name: "TCPクライアント"
#     ip: "127.0.0.1"
#     port: 9001
#     timeout: 5
#   function_request:
#     name: "xxx関数を実施しシナリオを切り替える"
#     id: 1 # 実行番号（応答時もこれと同じ番号を返す）
#     function_name: "dummy_execute_function_receiver00"
#     args:
#       - "1"
#       - 2
#       - "arg3"
begin
  body = YAML.load_file ARGV[0]
  raise "content-type error. [#{body['content-type']}]" if body['content-type'] != 'execute_function'
  raise "content-version error. [#{body['content-version']}]" if body['content-version'] != 0.1
  raise "not found 'contents'" unless body.has_key? 'contents'
  contents = body['contents']
  
  raise "not found 'stream_setting'" unless contents.has_key? 'stream_setting'
  stream_setting = contents['stream_setting']
  raise "not found 'stream_setting.ip'" unless stream_setting.has_key? 'ip'
  raise "not found 'stream_setting.port'" unless stream_setting.has_key? 'port'
  
  raise "not found 'function_request'" unless contents.has_key? 'function_request'
  function_request = contents['function_request']
  raise "not found 'function_request.function_name'" unless function_request.has_key? 'function_name'

  stream_setting.extend ExtendHash
  stream_setting = stream_setting.symbolize_keys
  
  execute_function_requestor = ExecuteFunctionRequestor.new stream_setting
  execute_function_requestor.start
  execute_function_requestor.send function_request
  execute_function_requestor.stop
rescue => e
  puts "ERROR:" + e.message
end

puts "complate."

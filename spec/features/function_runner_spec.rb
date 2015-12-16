# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../..'))

require 'yaml'
require 'function_executor'
require 'function_runner'
require 'log'
require 'yaml_reader'

require 'pry'

# ダミー実行関数群
$dummy_function_runner_args = Array.new
def dummy_function_runner00(arg0)
  $dummy_function_runner_args << arg0
end

describe 'FunctionRunner' do
  before do
    log = Log.instance
    log.disabled
    @function_executor = FunctionExecutor.new
    @function_executor.start
  end

  after do
    @function_executor.stop
  end
  
  context '生成／削除' do
    it '正しく生成／削除されることを確認' do
      function_runner = nil
      expect{ function_runner = FunctionRunner.new }.not_to raise_error
      expect{ function_runner.start }.not_to raise_error
      expect{ function_runner.stop }.not_to raise_error
    end
  end

  context '関数実行' do
    it '関数(引数あり:文字列)が実行できることを確認' do
      function_runner = nil
      expect{ function_runner = FunctionRunner.new }.not_to raise_error
      expect{ function_runner.start }.not_to raise_error
      message = {
        "content-type" => "message_fuction",
        "content-version" => 0.1,
        "contents" => {
          "function_name" => "dummy_function_runner00",
          "index" => 1,
          "description" => "dummy_function_runner00()呼び出し。引数あり",
          "args" => [
            { "type" => "char8", "value" => "ABCDEF" },
          ]
        }
      }
      expect{ function_runner.send message.to_yaml.to_s }.not_to raise_error
      # 応答待ち
      5.times do
        break if $dummy_function_runner_args.length != 0
        sleep 1
      end
      binding.pry
      # 関数実行結果を確認
      expect($dummy_function_runner_args.length).to eq 1
      expect($dummy_function_runner_args[0]).to eq "ABCDEF"
      yml = YAML.load(function_runner.recv_message)
      expect(yml["content-type"]).to eq "message_function_result"
      expect(yml["content-version"]).to eq 0.1
      expect(yml["contents"]["function_name"]).to eq "dummy_function_runner00"
      expect(yml["contents"]["index"]).to eq 1
      expect(yml["contents"]["result"]["type"]).to eq "int8"
      expect(yml["contents"]["result"]["value"]).to eq 1
      expect(yml["contents"]["result"]["message"]).to eq "success"
      # 後始末
      expect{ function_runner.stop }.not_to raise_error
    end
    
  end
end

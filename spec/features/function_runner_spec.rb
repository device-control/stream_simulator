# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src'))

require 'yaml'
require 'function_executor'
require 'function_runner'
require 'log'
require 'stream_data/yaml_reader'

require 'pry'

# ダミー実行関数群
$dummy_function_runner_args = Array.new
def dummy_function_runner00(arg0)
  $dummy_function_runner_args << arg0
end

describe 'FunctionRunner' do
  log = Log.instance
  log.disabled

  # before(:all) が実行されるのは最初の 1 回だけ
  # before(:each) が実行されるのは各 it ごと(describe,it,context...正確にはどの単位かは不明)
  before :all do
    @function_executor = FunctionExecutor.new
    @function_executor.start
  end

  after :all  do
    @function_executor.stop
  end
  
  context '生成／削除' do
    it '正しく生成／削除されることを確認' do
      expect{ FunctionRunner.new }.not_to raise_error
      expect{ FunctionRunner.new( '127.0.0.1' ) }.not_to raise_error
      expect{ FunctionRunner.new( '127.0.0.1', 9001 ) }.not_to raise_error
      expect{ FunctionRunner.new( '127.0.0.1', 9001, 5 ) }.not_to raise_error
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
      res = false
      expect{ res = function_runner.send message.to_yaml.to_s }.not_to raise_error
      # 関数実行結果を確認
      expect(res).to eq true
      # 後始末
      expect{ function_runner.stop }.not_to raise_error
    end
    
  end
end

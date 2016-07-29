# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src'))

require 'yaml'
require 'execute_function_receiver'
require 'execute_function_requestor'
require 'log'
require 'stream_data/yaml_reader'

require 'pry'

# ダミー実行関数群
$dummy_execute_function_requestor_args = Array.new
def dummy_execute_function_requestor00(arg0)
  $dummy_execute_function_requestor_args << arg0
end

describe 'ExecuteFunctionRequestor' do
  log = Log.instance
  log.disabled

  # before(:all) が実行されるのは最初の 1 回だけ
  # before(:each) が実行されるのは各 it ごと(describe,it,context...正確にはどの単位かは不明)
  before :all do
    @execute_function_receiver = ExecuteFunctionReceiver.new
    @execute_function_receiver.start
  end

  after :all  do
    @execute_function_receiver.stop
  end
  
  context '生成／削除' do
    it '正しく生成／削除されることを確認' do
      parameters = {
        :name => 'ExecuteFunctionRequestor',
        :type => :TCP_CLIENT,
        :ip => '127.0.0.1',
        :port => 9001,
        :timeout => 5,
      }
      expect{ ExecuteFunctionRequestor.new }.not_to raise_error
      expect{ ExecuteFunctionRequestor.new parameters }.not_to raise_error
      execute_function_requestor = nil
      expect{ execute_function_requestor = ExecuteFunctionRequestor.new }.not_to raise_error
      expect{ execute_function_requestor.start }.not_to raise_error
      expect{ execute_function_requestor.stop }.not_to raise_error
    end
  end

  context '関数実行' do
    it '関数(引数あり:文字列)が実行できることを確認' do
      execute_function_requestor = nil
      expect{ execute_function_requestor = ExecuteFunctionRequestor.new }.not_to raise_error
      expect{ execute_function_requestor.start }.not_to raise_error
      message = {
        "name" => "dummy_execute_function_requestor00()呼び出し。引数あり",
        "id" => 1,
        "function_name" => "dummy_execute_function_requestor00",
        "args" => [ "ABCDEF" ],
      }
      res = false
      expect{ res = execute_function_requestor.send message }.not_to raise_error
      # 関数実行結果を確認
      expect(res).to eq 0
      # 後始末
      expect{ execute_function_requestor.stop }.not_to raise_error
    end
    
  end
end

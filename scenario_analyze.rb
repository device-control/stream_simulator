# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'test_data'
require 'analyze_observer'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ScenarioAnalyze
  include AnalyzeObserver
  
  # コンストラクタ
  def initialize
    super()
  end
  
  # 解析結果通知
  def analyze_result_received(analyze, result)
    analyze(result)
  end
  
  # 解析処理
  def analyze(object)
    # シナリオを検索する
    # 対象のシナリオがなければ、解析を終了する
    scenario = TestData.instance.search_scenario(object.name)
    return if scenario.nil?
    
    # レスポンス名を取得する
    response = TestData.instance.create_response(scenario, object.name)
    return if response.nil?
    
    # レスポンスを通知
    notify_analyze_result(response)
  end
  
end

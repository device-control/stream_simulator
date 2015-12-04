# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'analyze_observer'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ScenarioAnalyze
  include AnalyzeObserver
  
  # コンストラクタ
  def initialize(testdata)
    super()
    
    @testdata = testdata
  end
  
  # 解析結果通知
  def analyze_result_received(analyze, result)
    analyze(result)
  end
  
  # 解析処理
  def analyze(object)
    # シナリオを検索する
    # 対象のシナリオがなければ、解析を終了する
    scenario = @testdata.search_scenario(object.name)
    return if scenario.nil?
    
    # レスポンス名を取得する
    response = @testdata.create_response(scenario, object.name)
    return if response.nil?
    
    # ログ出力
    Log.instance.info "#{self.class}##{__method__}: response --->"
    response.to_log
    
    # レスポンスを通知
    notify_analyze_result(response.encode)
  end
  
end

# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'message_utils'
require 'analyze_observer'
require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ScenarioAnalyze
  include MessageUtils
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
    # レスポンスを取得する
    response = @testdata.create_response(object)
    return if response.nil?
    
    # ログ出力
    Log.instance.info "#{self.class}##{__method__}: response --->"
    response.to_log
    
    # レスポンスを通知
    message = hex_string_to_binary(response.encode())
    notify_analyze_result(message)
  end
  
end

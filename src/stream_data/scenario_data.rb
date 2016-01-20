# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ScenarioData
  
  TARGET_CONTENT_TYPE    = 'scenario_data'
  TARGET_CONTENT_VERSION = '0.1'
  
  NAME           = 'name'
  DESCRIPTION    = 'description'
  SEQUENCE       = 'sequence'
  REQUEST_FORMAT = 'request_format'
  RESPONSE_DATA  = 'response_data'
  
  attr_accessor :name
  attr_accessor :description
  attr_accessor :sequences
  
  # コンストラクタ
  def initialize(contents)
    create_contents(contents)
  end
  
  # コンテンツを生成
  def create_contents(contents)
    @name = contents[NAME]
    @description = contents[DESCRIPTION]
    create_sequence(contents)
  end
  
  # シーケンスを生成する
  def create_sequence(contents)
    @sequences = Hash.new
    contents[SEQUENCE].each do |s|
      request = s[REQUEST_FORMAT]
      response = s[RESPONSE_DATA]
      if @sequences.has_key?(request)
        Log.instance.warn("#{self.class}##{__method__}: #{request} already exists.")
        next
      end
      @sequences[request] = response
    end
  end
  
  # 対象のコマンドかどうか
  def target?(request)
    return true if @sequences[request]
    return false
  end
  
  # レスポンスを取得する
  def get_response(request)
    return @sequences[request]
  end
  
end

# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamData
  
  attr_reader :message_formats
  attr_reader :message_entities
  attr_reader :scenarios
  attr_reader :sequences
  attr_reader :autopilots
  
  # コンストラクタ
  def initialize(message_formats, message_entities, scenarios, sequences, autopilots)
    @message_formats = message_formats
    @message_entities = message_entities
    @scenarios = scenarios
    @sequences = sequences
    @autopilots = autopilots
  end
  
#   # 対象シナリオを検索する
#   def search_scenario(message_object)
#     @scenario_datas.each do |name, scenario|
#       return scenario if scenario.target?(message_object.name)
#     end
#     return nil
#   end
  
#   # レスポンスを生成する
#   # 対象のシナリオからレスポンスを取得し、データを生成する
#   def create_response(message_object)
#     # 対象のシナリオを検索
#     scenario = search_scenario(message_object)
#     return nil if scenario.nil?
#     # レスポンス名を取得
#     response = scenario.get_response(message_object.name)
#     return nil if response.nil?
    
#     message = @message_objects[response]
#     return message
#   end
  
end

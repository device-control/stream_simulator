# coding: utf-8

require 'log'
require 'stream_data/yaml_reader'
require 'stream_data/stream_data'
require 'stream_data/message_format'
require 'stream_data/message_entity'
require 'stream_data/sequence'
require 'stream_data/scenario'
require 'stream_data/autopilot'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module StreamDataCreator
  include YamlReader
  
  # Yamlオブジェクトを内部用にリメイクする
  def remake_yamls(_yamls)
    yamls = Hash.new
    yamls[:message_structs] = yamls_by_name _yamls, "message_struct"
    yamls[:message_formats] = yamls_by_name _yamls, "message_format"
    yamls[:message_entities] = yamls_by_name _yamls, "message_entity"
    yamls[:scenarios] = yamls_by_name _yamls, "scenario"
    yamls[:sequences] = yamls_by_name _yamls, "sequence"
    yamls[:autopilots] = yamls_by_name _yamls, "autopilot"
    return yamls
  end
  
  # StreamData を生成する
  def create(path)
    # yamlファイル読込み
    yamls = get_yamls(path)
    yamls = remake_yamls(yamls)
    
    stream_data = StreamData.new
    # メッセージフォーマットを生成
    stream_data.message_formats = get_message_formats yamls, yamls[:message_structs]
    # メッセージエンティティを生成
    stream_data.message_entities = get_message_entities yamls, stream_data.message_formats
    # シーケンスを生成
    stream_data.sequences = get_sequences yamls
    # シナリオを生成
    stream_data.scenarios = get_scenarios yamls, stream_data.sequences
    # オートパイロットを生成
    stream_data.autopilots = get_autopilots yamls
    
    return stream_data
  end
  
  # ---
  # message_formats取得
  def get_message_formats(yamls, message_structs)
    formats = Hash.new
    yamls[:message_formats].each do |name, yaml|
      formats[name] = MessageFormat.create name, yaml, message_structs
    end
    return formats
  end
  
  # ---
  # message_entities取得
  def get_message_entities(yamls, message_formats)
    entities = Hash.new
    yamls[:message_entities].each do |name, yaml|
      entities[name] = MessageEntity.create name, yaml, message_formats
    end
    return entities
  end
  
  # ---
  # sequences取得
  def get_sequences(yamls)
    sequences = Hash.new
    yamls[:sequences].each do |name, yaml|
      sequences[name] = Sequence.create name, yaml
    end
    return sequences
  end
  
  # ---
  # scenarios取得
  def get_scenarios(yamls, sequences)
    scenarios = Hash.new
    yamls[:scenarios].each do |name, yaml|
      scenarios[name] = Scenario.create name, yaml, sequences
    end
    return scenarios
  end
  
  # ---
  # autopilots取得
  def get_autopilots(yamls)
    autopilots = Hash.new
    yamls[:autopilots].each do |name, yaml|
      autopilots[name] = Autopilot.create name, yaml
    end
    return autopilots
  end
  
end

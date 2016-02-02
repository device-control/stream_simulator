# coding: utf-8

require 'log'
require 'stream_data/yaml_reader'
require 'stream_data/stream_data'
require 'stream_data/stream_setting'
require 'stream_data/message_format'
require 'stream_data/message_entity'
require 'stream_data/sequence'
require 'stream_data/scenario'
require 'stream_data/autopilot'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module StreamDataCreator
  include YamlReader
  
  # StreamData を生成する
  def create(path)
    raise "path is nil" if path.nil?
    
    # yamlファイル読込み
    yamls = get_yamls(path)
    yamls = remake_yamls(yamls)
    
    stream_data = StreamData.new
    # ストリーム設定を生成
    stream_data.stream_settings = get_stream_settings yamls
    # メッセージ構造体を生成
    stream_data.message_structs = get_message_structs yamls, yamls[:message_structs]
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
    
    # 変数を生成
    variables = Hash.new
    add_variables_from_messages variables, stream_data.message_formats
    add_variables_from_messages variables, stream_data.message_entities
    add_variables_from_sequences variables, stream_data.sequences
    stream_data.variables = variables
    
    return stream_data
  end
  
  # Yamlオブジェクトを内部用にリメイクする
  def remake_yamls(_yamls)
    yamls = Hash.new
    yamls[:message_structs] = yamls_by_name _yamls, 'message_struct'
    yamls[:message_formats] = yamls_by_name _yamls, 'message_format'
    yamls[:message_entities] = yamls_by_name _yamls, 'message_entity'
    yamls[:scenarios] = yamls_by_name _yamls, 'scenario'
    yamls[:sequences] = yamls_by_name _yamls, 'sequence'
    yamls[:autopilots] = yamls_by_name _yamls, 'autopilot'
    yamls[:stream_settings] = yamls_by_name _yamls, 'stream_setting'
    return yamls
  end
  
  # stream_settings 取得
  def get_stream_settings(yamls)
    stream_settings = Hash.new
    yamls[:stream_settings].each do |name, yaml|
      stream_settings[name] = StreamSetting.create name, yaml
    end
    return stream_settings
  end
  
  # message_structs 取得
  def get_message_structs(yamls, message_structs)
    structs = Hash.new
    yamls[:message_structs].each do |name, yaml|
      structs[name] = MessageFormat.create name, yaml, message_structs
    end
    return structs
  end
  
  # message_formats 取得
  def get_message_formats(yamls, message_structs)
    formats = Hash.new
    yamls[:message_formats].each do |name, yaml|
      formats[name] = MessageFormat.create name, yaml, message_structs
    end
    return formats
  end
  
  # message_entities 取得
  def get_message_entities(yamls, message_formats)
    entities = Hash.new
    yamls[:message_entities].each do |name, yaml|
      entities[name] = MessageEntity.create name, yaml, message_formats
    end
    return entities
  end
  
  # sequences 取得
  def get_sequences(yamls)
    sequences = Hash.new
    yamls[:sequences].each do |name, yaml|
      sequences[name] = Sequence.create name, yaml
    end
    return sequences
  end
  
  # scenarios 取得
  def get_scenarios(yamls, sequences)
    scenarios = Hash.new
    yamls[:scenarios].each do |name, yaml|
      scenarios[name] = Scenario.create name, yaml, sequences
    end
    return scenarios
  end
  
  # autopilots 取得
  def get_autopilots(yamls)
    autopilots = Hash.new
    yamls[:autopilots].each do |name, yaml|
      autopilots[name] = Autopilot.create name, yaml
    end
    return autopilots
  end
  
  # variables に変数を追加
  # messages の values の値がSymbolなら variables にSymbolを設定し、初期化する
  def add_variables_from_messages(variables, messages)
    return if messages.nil?
    # messages のvaluesから変数を取得
    messages.each do |name, message|
      message.values.each do |member_name, value|
        member_data = message.get_member member_name
        if value.class == Symbol
          variables[value] = member_data.default_value unless variables.has_key? value
        end
      end
    end
  end
  
  # variables に変数を追加
  # sequences の commands から variables にSymbolを設定し、初期化する
  def add_variables_from_sequences(variables, sequences)
    return if sequences.nil?
    # sequences のcommandsから変数を取得
    sequences.each do |name, sequence|
      sequence.commands.each do |command|
        next if command[:name].nil?
        if command[:name] == :SET_VARIABLE
          next if command[:arguments].nil?
          next if command[:arguments][:exec].nil?
          execute_list = command[:arguments][:exec]
          execute_list = Array.new [execute_list] unless execute_list.instance_of? Array
          execute_list.each do |exec|
            exec.scan(/\:([0-9a-zA-Z_]+)/) do |w|
              symbol = $1.to_sym
              variables[symbol] = 0 unless variables.has_key? symbol
            end
          end
        end
      end
    end
  end
  
end

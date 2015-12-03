# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'yaml_reader'
require 'message_format'
require 'message_data'
require 'scenario_data'
require 'message_object'
require "log"

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class TestData
  
  CONTENT_TYPE    = 'content-type'
  CONTENT_VERSION = 'content-version'
  CONTENTS        = 'contents'
  
  attr_reader :yamls
  attr_reader :message_formats
  attr_reader :message_datas
  attr_reader :scenario_datas
  attr_reader :message_objects
  
  # コンストラクタ
  def initialize(path)
    load(path)
  end
  
  # データクリア
  def clear
    @yamls = Array.new
    @message_formats = Hash.new
    @message_datas = Hash.new
    @scenario_datas = Hash.new
    @message_objects = Hash.new
  end
  
  # 指定されたPathのymlファイルを読み込み
  # 各コンテンツを生成する
  def load(path)
    clear()
    
    @yamls = YamlReader.get_yamls(path)
    @yamls.each do |yaml|
      add_objects(yaml, @message_formats, MessageFormat)
      add_objects(yaml, @message_datas, MessageData)
      add_objects(yaml, @scenario_datas, ScenarioData)
    end
    make_message_objects()
  end
  
  # 対象クラスを生成し、登録する
  def add_objects(data, container, target_class)
    type = data[CONTENT_TYPE]
    version = data[CONTENT_VERSION]
    contents = data[CONTENTS]
    
    return unless target_class::TARGET_CONTENT_TYPE == type
    return unless target_class::TARGET_CONTENT_VERSION == version
    
    object = target_class.new(contents)
    
    if container.has_key?(object.name)
      Log.instance.warn "#{self.class}##{__method__}: #{object.name} already exists in #{target_class}."
      return
    end
    
    # オブジェクトをセット
    container[object.name] = object
  end
  
  # メッセージデータを元にメッセージオブジェクトを生成する
  def make_message_objects
    @message_datas.each do |name, data|
      # 同一名のメッセージＮＧ
      if @message_objects.has_key?(name)
        Log.instance.warn "#{self.class}##{__method__}: #{name} already exists in messages."
        next
      end
      # フォーマットが見つからなければＮＧ
      format = @message_formats[data.using_format]
      if format.nil?
        Log.instance.warn "#{self.class}##{__method__}: #{name} not found format."
        next
      end
      
      message_object = MessageObject.new(name, format, format.default_data)
      message_object.update_data(data.update_data)
      @message_objects[name] = message_object
    end
  end
  
  # 対象のフォーマットを検索する
  def search_message_format(message)
    @message_formats.each do |name, format|
      if format.target?(message)
        return format
      end
    end
    return nil
  end
  
  # 対象シナリオを検索する
  def search_scenario(command)
    @scenario_datas.each do |name, scenario|
      return scenario if scenario.target?(command)
    end
    return nil
  end
  
  # レスポンスを生成する
  # シナリオから対象のレスポンスを取得し、データを生成する
  def create_response(scenario, command)
    response = scenario.get_response(command)
    return nil if response.nil?
    
    message = @message_objects[response]
    return nil if message.nil?
    
    return message.encode()
  end
  
  # メッセージオブジェクトを生成
  def create_message_object(message, message_format)
    data = message_format.decode(message)
    return MessageObject.new(message_format.name, message_format, data)
  end
  
end

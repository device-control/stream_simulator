# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'
require 'yaml_reader'
require 'stream_data'
require 'message_format'
require 'message_entity'
require 'scenario'
require 'autopilot'
require 'member_data_creator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamDataCreator
  include YamlReader
  
  CONTENT_TYPE    = 'content-type'
  CONTENT_VERSION = 'content-version'
  CONTENTS        = 'contents'
  
  attr_reader :yamls
  
  # コンストラクタ
  def initialize(path)
    # yamlファイル読込み
    _yamls = get_yamls(path)
    # リメイク
    @yamls = remake_yamls(_yamls)
  end
  
  # Yamlオブジェクトを内部用にリメイクする
  def remake_yamls(_yamls)
    yamls = Hash.new
    yamls[:structs] = yamls_by_name(_yamls, "message_struct")
    yamls[:formats] = yamls_by_name(_yamls, "message_format")
    yamls[:entities] = yamls_by_name(_yamls, "message_entity")
    yamls[:scenarios] = yamls_by_name(_yamls, "scenario")
    yamls[:autopilots] = yamls_by_name(_yamls, "autopilot")
    return yamls
  end
  
  # yamlsをnameをキーとしてHashにする
  # 指定typeのみを対象とする
  def yamls_by_name(yamls, type)
    hash = Hash.new
    yamls.each.with_index do |yaml,index|
      yaml_obj = yaml[:body]
      next if yaml_obj[CONTENT_TYPE] != type
      contents = yaml_obj[CONTENTS]
      name = contents["name"]
      if hash.has_key?(name)
        Log.instance.warn "#{self.class}##{__method__}: Multiple define name: type=[#{type}] name=[#{name}] file=[#{yaml[:file]}]"
        next
      end
      hash[name] = yaml
    end
    return hash
  end
  
  # StreamData を生成する
  def create()
    message_formats = get_message_formats()
    message_entities = get_message_entities(message_formats)
    scenarios = get_scenarios()
    autopilots = get_autopilots()
    return StreamData.new(message_formats, message_entities, scenarios, autopilots)
  end
  
  # message_formats取得
  def get_message_formats()
    formats = Hash.new
    @yamls[:formats].each do |name, yaml|
      formats[name] = create_message_format(name, yaml)
    end
    return formats
  end
  
  # message_entities取得
  def get_message_entities(message_formats)
    entities = Hash.new
    @yamls[:entities].each do |name, yaml|
      entities[name] = create_message_entity(name, yaml, message_formats)
    end
    return entities
  end
  
  # scenarios取得
  def get_scenarios()
    scenarios = Hash.new
    @yamls[:scenarios].each do |name, yaml|
      scenarios[name] = create_scenario(name, yaml)
    end
    return scenarios
  end
  
  # autopilots取得
  def get_autopilots()
    autopilots = Hash.new
    @yamls[:autopilots].each do |name, yaml|
      autopilots[name] = create_autopilot(name, yaml)
    end
    return autopilots
  end
  
  
  # ---
  # メッセージフォーマット生成処理
  def create_message_format(name, yaml)
    # MessageFormatの情報を生成
    @creating_format = Hash.new
    @creating_format[:member_list] = Array.new
    @creating_format[:member_total_size] = 0
    @creating_format[:members] = Hash.new
    @creating_format[:primary_key] = yaml[:body]["contents"]["primary_key"] || Hash.new
    @creating_format[:default_values] = yaml[:body]["contents"]["default_values"] || Hash.new
    
    nested_member_names = Array.new
    generate_members(nested_member_names, yaml[:body]['contents']['format'], @creating_format[:members])
    
    # MessageFormatを生成
    message_format = MessageFormat.new(name,
                                       yaml[:file],
                                       @creating_format[:member_list],
                                       @creating_format[:member_total_size],
                                       @creating_format[:members],
                                       @creating_format[:primary_key])
    
    # MessageFormatにプライマリキーの値を設定
    set_primary_key(message_format)
    # MessageFormatにデフォルト値を設定
    set_default_values(message_format)
    
    return message_format
  end
  
  # membersを生成する
  def generate_members(nested_member_names, format, members)
    format.each do |member|
      # メンバーの構成をリメイク
      member = remake_member(member)
      
      # 構造体の場合
      struct = get_struct(member['type'])
      unless struct.nil?
        analyze_struct(nested_member_names, member, struct, members)
        next
      end
      
      # 最小構成の場合
      generate_member(nested_member_names, member, members)
    end
  end
  
  # 構造体を解析する
  def analyze_struct(nested_member_names, member, struct, members)
    if member['count'].nil?
      # 配列でない場合
      nested_member_names_now =  nested_member_names.clone
      nested_member_names_now << member['name']
      # 構造体のメンバーを取得
      members[member['name']] =Hash.new
      generate_members(nested_member_names_now, struct[:body]['contents']['struct'], members[member['name']])
    else
      # 配列の場合
      members[member['name']] = Array.new(member['count'])
      member['count'].times do |index|
        nested_member_names_now =  nested_member_names.clone
        nested_member_names_now << member['name'] + "[#{index}]"
        # 構造体のメンバーを取得
        members[member['name']][index] =Hash.new
        generate_members(nested_member_names_now, struct[:body]['contents']['struct'], members[member['name']][index])
      end
    end
  end
  
  # メンバーを生成する
  def generate_member(nested_member_names, member, members)
    if member['count'].nil? || !MemberDataCreator.use_array?(member)
      # 配列でない場合
      add_member(nested_member_names, member, members)
    else
      # 配列の場合
      members[member['name']] = Array.new(member['count'])
      member['count'].times do |index|
        add_member(nested_member_names, member, members, index)
      end
    end
  end
  
  # メンバーを追加する
  def add_member(nested_member_names, member, members, index=nil)
    # フルメンバー名を生成
    nested_member_names_now =  nested_member_names.clone
    nested_member_names_now << member['name']
    full_member_name = nested_member_names_now.join('.')
    full_member_name += "[#{index}]" if index
    
    # フルメンバー名の重複確認
    if member_name_include?(full_member_name)
      raise "ERROR: #{self.class}##{__method__}: Multiple member name [#{full_member_name}] file=[#{@file}]"
    end
    
    # メンバーを追加
    member_data = MemberDataCreator.create(member, @creating_format[:member_total_size])
    if index.nil?
      # 配列でない場合
      members[member['name']] = member_data
    else
      # 配列の場合
      members[member['name']][index] = member_data
    end
    @creating_format[:member_list] << full_member_name
    @creating_format[:member_total_size] += member_data.size
  end
  
  # structを取得する
  def get_struct(member_type)
    return @yamls[:structs][member_type]
  end
  
  # メンバーの構成をリメイク
  # メンバー名を名前と配列数に分離する
  def remake_member(member)
    ret = member.clone
    if m = member['name'].match(/^(.+)\[([0-9]+)\]/)
      ret['name'] = m[1]
      ret['count'] = m[2].to_i
    end
    return ret
  end
  
  # @member_list に member_name が含まれているか確認
  def member_name_include?(member_name)
    escape_name = Regexp.escape member_name
    @creating_format[:member_list].each do |include_name|
      if include_name.match(/^#{escape_name}/)
        return true
      end
    end
    return false
  end
  
  # プライマリキー値をセット
  def set_primary_key(message_format)
    @creating_format[:primary_key].each do |key, value|
      message_format.set_value(key, value)
    end
  end
  
  # デフォルト値をセット
  def set_default_values(message_format)
    @creating_format[:default_values].each do |key, value|
      if @creating_format[:primary_key].include?(key)
        # プライマリキーに設定されている場合、セットしない
        Log.instance.warn "#{self.class}##{__method__}: Already defined in the primary_key: key=[#{key}] file=[#{@file}]"
        next
      end
      message_format.set_value(key, value)
    end
  end
  
  # ---
  # メッセージエンティティ生成処理
  def create_message_entity(name, yaml, message_formats)
    using_format = yaml[:body]['contents']['using_format']
    if using_format.nil?
      raise "ERROR: #{self.class}##{__method__}: using_format is not defined. file=[#{yaml[:file]}]"
    end
    
    format = message_formats[using_format]
    if format.nil?
      raise "ERROR: #{self.class}##{__method__}: Not found format. format=[#{using_format}] file=[#{yaml[:file]}]"
    end
    
    return MessageEntity.new(name, yaml[:file], format, yaml[:body]['contents']['values'])
  end
  
  # ---
  # シナリオ生成処理
  def create_scenario(name, yaml)
    sequence = yaml[:body]['contents']['sequence']
    if sequence.nil?
      raise "ERROR: #{self.class}##{__method__}: sequence is not defined. file=[#{yaml[:file]}]"
    end
    
    return Scenario.new(name, yaml[:file], sequence)
  end
  
  # ---
  # オートパイロット生成処理
  def create_autopilot(name, yaml)
    autopilot = yaml[:body]['contents']['autopilot']
    if autopilot.nil?
      raise "ERROR: #{self.class}##{__method__}: autopilot is not defined. file=[#{yaml[:file]}]"
    end
    
    return Autopilot.new(name, yaml[:file], autopilot)
  end
  
end
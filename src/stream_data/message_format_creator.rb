# coding: utf-8

require 'log'
require 'stream_data/message_format'
require 'stream_data/member_data/member_data_creator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module MessageFormatCreator
  
  # MessageFormat を生成する
  def create(name, yaml, message_structs)
    raise "yaml is nil" if yaml.nil?
    raise "not found file" unless yaml.has_key? :file
    raise "not found body" unless yaml.has_key? :body
    raise "not found contents" unless yaml[:body].has_key? 'contents'
    raise "not found members" unless yaml[:body]['contents'].has_key? 'members'
    
    # 作成中のフォーマット情報
    creating_info = Hash.new
    creating_info[:member_list] = Array.new
    creating_info[:member_total_size] = 0
    creating_info[:values] = Hash.new
    
    # menbersを生成
    nested_member_names = Array.new
    out_members = Hash.new
    generate_members creating_info, nested_member_names, yaml[:body]['contents']['members'], out_members, message_structs
    
    # プライマリキーの値を設定
    primary_keys = yaml[:body]['contents']['primary_keys'] || Hash.new
    primary_keys.each do |key, value|
      raise "not found [#{key}] in member_list" unless creating_info[:member_list].include? key
      creating_info[:values][key] = value
    end
    # デフォルト値を設定
    default_values = yaml[:body]['contents']['default_values'] || Hash.new
    default_values.each do |key, value|
      raise "not found [#{key}] in member_list" unless creating_info[:member_list].include? key
      raise "already defined [#{key}] in primary_keys" if primary_keys.has_key? key
      creating_info[:values][key] = value
    end
    
    # MessageFormatを生成
    return MessageFormat.new(name,
                             yaml[:file],
                             creating_info[:member_list],
                             creating_info[:member_total_size],
                             out_members,
                             creating_info[:values],
                             primary_keys
                            )
  end
  
  # membersを生成する
  def generate_members(creating_info, nested_member_names, members, out_members, message_structs)
    raise "members is nil" if members.nil?
    raise "members not Array" unless members.instance_of? Array
    
    members.each do |member|
      raise "not found name_jp" unless member.has_key? 'name_jp'
      raise "not found name" unless member.has_key? 'name'
      raise "not found type" unless member.has_key? 'type'
      
      # メンバーの構成をリメイク
      member = remake_member member
      # 構造体の場合
      struct = message_structs[member['type']]
      unless struct.nil?
        analyze_struct creating_info, nested_member_names, member, struct, out_members, message_structs
        next
      end
      # 最小構成の場合
      generate_member creating_info, nested_member_names, member, out_members
    end
  end
  
  # 構造体を解析する
  def analyze_struct(creating_info, nested_member_names, member, struct, out_members, message_structs)
    raise "struct is nil" if struct.nil?
    raise "not found file" unless struct.has_key? :file
    raise "not found body" unless struct.has_key? :body
    raise "not found contents" unless struct[:body].has_key? 'contents'
    raise "not found members" unless struct[:body]['contents'].has_key? 'members'
    
    if member['count'].nil?
      # 配列でない場合
      nested_member_names_now =  nested_member_names.clone
      nested_member_names_now << member['name']
      # 構造体のメンバーを取得
      out_members[member['name']] =Hash.new
      generate_members creating_info, nested_member_names_now, struct[:body]['contents']['members'], out_members[member['name']], message_structs
    else
      # 配列の場合
      out_members[member['name']] = Array.new member['count']
      member['count'].times do |index|
        nested_member_names_now =  nested_member_names.clone
        nested_member_names_now << member['name'] + "[#{index}]"
        # 構造体のメンバーを取得
        out_members[member['name']][index] =Hash.new
        generate_members creating_info, nested_member_names_now, struct[:body]['contents']['members'], out_members[member['name']][index], message_structs
      end
    end
  end
  
  # メンバーを生成する
  def generate_member(creating_info, nested_member_names, member, out_members)
    if member['count'].nil? || (!MemberDataCreator.use_array? member)
      # 配列でない場合
      add_member creating_info, nested_member_names, member, out_members
    else
      # 配列の場合
      out_members[member['name']] = Array.new(member['count'])
      member['count'].times do |index|
        add_member creating_info, nested_member_names, member, out_members, index
      end
    end
  end
  
  # メンバーを追加する
  def add_member(creating_info, nested_member_names, member, out_members, index=nil)
    # フルメンバー名を生成
    nested_member_names_now =  nested_member_names.clone
    nested_member_names_now << member['name']
    full_member_name = nested_member_names_now.join '.'
    full_member_name += "[#{index}]" if index
    
    # フルメンバー名の重複確認
    if member_name_include? creating_info[:member_list], full_member_name
      raise "multiple member name [#{full_member_name}]"
    end
    
    # メンバーを追加
    member_data = MemberDataCreator.create member, creating_info[:member_total_size]
    if index.nil?
      # 配列でない場合
      out_members[member['name']] = member_data
    else
      # 配列の場合
      out_members[member['name']][index] = member_data
    end
    creating_info[:member_list] << full_member_name
    creating_info[:member_total_size] += member_data.size
    creating_info[:values][full_member_name] = member_data.default_value
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
  
  # member_list に member_name が含まれているか確認
  def member_name_include?(member_list, member_name)
    escape_name = Regexp.escape member_name
    member_list.each do |include_name|
      if include_name.match(/^#{escape_name}/)
        return true
      end
    end
    return false
  end
  
end

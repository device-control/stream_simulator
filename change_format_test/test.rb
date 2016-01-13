# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "hashie"
require "yaml_reader"
require "pp"

require "pry"

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

def yamls_by_name(yamls, type)
  hash = Hash.new
  yamls.each.with_index do |yaml,index|
    yaml_obj = yaml[:body]
    next if yaml_obj["content-type"] != type
    contents = yaml_obj["contents"]
    name = contents["name"]
    if hash.has_key?(name)
      puts "WARNING: yamls_by_name: multiple define name:[#{type}] [#{name}] [#{yaml[:file]}]"
      next
    end
    hash[name] = yaml
  end
  return hash
end

def remake_yamls(_yamls)
  yamls = Hash.new
  yamls[:bases] = yamls_by_name(_yamls,"base")
  yamls[:structs] = yamls_by_name(_yamls,"struct")
  yamls[:formats] = yamls_by_name(_yamls,"format")
  return yamls
end

def get_size(type)
  return 1 if type == 'int8'
  return 2 if type == 'int16'
  return 4 if type == 'int32'
  return 1 if type == 'char'
  raise "get_size: unknown type \"#{type}\""
end

def get_value(member_names, hmember, member_list, members, members_size)
  # puts "=== get_value[#{hmember.name}]"
  # 最小型ならそのまま保持
  if hmember.type.match(/int8|int16|int32|char/)
    member_name = hmember.name
    size = get_size(hmember.type)
    if m = member_name.match(/^(.+)\[([0-9]+)\]/)
      # 配列の場合
      member_name = m[1]
      members[member_name] = Hash.new
      pmembers = members[member_name]
      if hmember.type == 'char'
        pmembers[:value] = 0 # 初期値=0
      else
        pmembers[:value] = Array.new m[2].to_i, 0 # 初期値=0
      end
      pmembers[:name_jp] = hmember.name_jp
      pmembers[:type] = hmember.type
      size = size * m[2].to_i
    else
      # 配列でない場合
      members[member_name] = Hash.new
      pmembers = members[member_name]
      pmembers[:value] = 0 # 初期値
      pmembers[:name_jp] = hmember.name_jp
      pmembers[:type] = hmember.type
    end
    # 名前登録とサイズ登録
    member_names << member_name
    all_member_name = member_names.join('.')
    member_list << all_member_name
    if members_size.has_key?(all_member_name)
      raise "get_value: multiple member name \"#{all_member_name}\""
    end
    members_size[all_member_name] = size
    members_size[:TOTAL_SIZE] += size
    return true
  end
  return false # FIXME: ここも例外のほうがいいか？？
end

def get_struct(member_names, yamls, base_hmember, member_list, members, members_size)
  member_name = base_hmember.name
  # puts "=== get_value[#{member_name}]"
  
  if m = member_name.match(/^(.+)\[([0-9]+)\]/)
    member_name = m[1]
    # 配列の場合
    raise "get_struct: does not exist type \"#{base_hmember.type}\" of Array." if !yamls[:structs].has_key?(base_hmember.type)
    target_struct = yamls[:structs][base_hmember.type]
    members[member_name] = Array.new(m[2].to_i)
    m[2].to_i.times do |index|
      member_names_now = member_names.clone

      members[member_name][index] = Hash.new
      pmembers = members[member_name][index]
      member_names_now << member_name + "[#{index}]" # 配列用
      
      target_struct[:body]["contents"]["format"].each do |member|
        hmember = Hashie::Mash.new member
        member_names_now2 = member_names_now.clone # メンバ用
        # 最小構成
        next if get_value(member_names_now2, hmember,         member_list, pmembers, members_size)
        # 構造体
        next if get_struct(member_names_now2, yamls, hmember, member_list, pmembers, members_size)
        # TODO: ここに来たら異常フォーマット
      end
    end
  else
    # ただの構造体の場合
    raise "get_struct: does not exist type \"#{base_hmember.type}\" of Array." if !yamls[:structs].has_key?(base_hmember.type)
    target_struct = yamls[:structs][base_hmember.type]
    members[member_name] = Hash.new
    pmembers = members[member_name]
    member_names << member_name
    target_struct[:body]["contents"]["format"].each do |member|
      hmember = Hashie::Mash.new member
      member_names_now = member_names.clone
      # 最小構成
      next if get_value(member_names_now, hmember,         member_list, pmembers, members_size)
      # 構造体
      next if get_struct(member_names_now, yamls, hmember, member_list, pmembers, members_size)
      # TODO: ここに来たら異常フォーマット
    end
  end
end

def set_value(format, key, value)
  hmembers = format[:hmembers]
  # TODO: hmembers に key が存在しない場合の異常検出が必要
  begin
    member_value = "hmembers.#{key}.value"
    member_type = "hmembers.#{key}.type"
    if m = key.match(/^(.+)(\[[0-9]+\])$/)
      # 配列の場合はvalue[x]にする
      member_value = "hmembers.#{m[1]}.value#{m[2]}"
      member_type = "hmembers.#{m[1]}.type"
    end
    type = eval member_type
    if type == 'char'
      eval "#{member_value}=\"#{value}\""
    else
      eval "#{member_value}=#{value}"
    end
  rescue => e
    puts "ERROR: get_value: " + e.message
  end
end

def get_format(yamls)
  formats = Hash.new
  # TODO: メンバ名の重複チェックが必要
  begin
    yamls[:formats].each do |name,yaml|
      # puts "=== target[#{name}]"
      member_list = Array.new # memberの順番
      members_size = Hash.new # memberのサイズ
      members = Hash.new # name_jp, type, value
      
      members_size[:TOTAL_SIZE] = 0 # 全メンバサイズ合計 :TOTAL_SIZE は予約語とする。
      yaml[:body]["contents"]["format"].each do |member|
        hmember = Hashie::Mash.new member
        member_names = Array.new
        # 最小構成
        next if get_value(member_names, hmember,         member_list, members, members_size)
        # 構造体
        next if get_struct(member_names, yamls, hmember, member_list, members, members_size)
        # TODO: ここに来たら異常フォーマット
      end
      # 出力設定
      formats[name] = Hash.new
      formats[name][:member_list] = member_list
      formats[name][:members_size] = members_size
      formats[name][:hmembers] = Hashie::Mash.new members
      
      # 初期値設定
      yaml[:body]["contents"]["default_values"].each do |key,value|
        set_value(formats[name],key,value)
      end
    end
  rescue => e
    puts "ERROR: get_format: " + e.message
    exit
  end
  return formats
end

_yamls = YamlReader::get_yamls("yml")
yamls = remake_yamls(_yamls)
formats = get_format(yamls)
pp formats["test00"].to_hash

puts "終了"


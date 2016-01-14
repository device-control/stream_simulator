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

# member_list          : 全メンバ名のリスト(array)
# nested_member_names  : 階層メンバ名(array)
# member_name          : 登録対象のメンバ名
def add_member_name(member_list, nested_member_names, member_name)
  nested_member_names << member_name
  all_member_name = nested_member_names.join('.')
  
  # メンバ名の重複確認
  if member_name_include?(member_list, all_member_name)
    raise "get_value: multiple member name \"#{all_member_name}\""
  end
  # メンバ登録
  member_list << all_member_name
end

def get_value(nested_member_names, hmember, member_list, members)
  # puts "=== get_value[#{hmember.name}]"
  # 最小型ならそのまま保持
  if hmember.type.match(/int8|int16|int32|char/)
    member_name = hmember.name
    size = get_size(hmember.type)
    if m = member_name.match(/^(.+)\[([0-9]+)\]/)
      # 配列の場合
      member_name = m[1]
      if hmember.type == 'char'
        # char の場合、配列にしない
        size = size * m[2].to_i
        members[member_name] = Hash.new
        pmembers = members[member_name]
        
        pmembers[:value] = '' # 初期値=''
        pmembers[:name_jp] = hmember.name_jp
        pmembers[:type] = hmember.type
        pmembers[:offset] = @member_total_size
        pmembers[:size] = size
        add_member_name(member_list, nested_member_names, member_name)
        @member_total_size += size
      else
        # int の場合、配列にする
        members[member_name] = Array.new m[2].to_i
        m[2].to_i.times do |index|
          nested_member_names_now = nested_member_names.clone
          
          members[member_name][index] = Hash.new
          pmembers = members[member_name][index]
          
          pmembers[:value] = 0 # 初期値=0
          pmembers[:name_jp] = hmember.name_jp
          pmembers[:type] = hmember.type
          pmembers[:offset] = @member_total_size
          pmembers[:size] = size;
          add_member_name(member_list, nested_member_names_now, member_name+"[#{index}]")
          @member_total_size += size
        end
      end
    else
      # 配列でない場合
      members[member_name] = Hash.new
      pmembers = members[member_name]
      
      pmembers[:value] = 0 # 初期値
      pmembers[:name_jp] = hmember.name_jp
      pmembers[:type] = hmember.type
      pmembers[:offset] = @member_total_size
      pmembers[:size] = size
      add_member_name(member_list, nested_member_names, member_name)
      @member_total_size += size
    end
    return true
  end
  return false # FIXME: ここも例外のほうがいいか？？
end

def get_struct(nested_member_names, yamls, base_hmember, member_list, members)
  member_name = base_hmember.name
  # puts "=== get_value[#{member_name}]"
  
  if m = member_name.match(/^(.+)\[([0-9]+)\]/)
    member_name = m[1]
    # 配列の場合
    raise "get_struct: does not exist type \"#{base_hmember.type}\" of Array." if !yamls[:structs].has_key?(base_hmember.type)
    target_struct = yamls[:structs][base_hmember.type]
    members[member_name] = Array.new(m[2].to_i)
    m[2].to_i.times do |index|
      nested_member_names_now = nested_member_names.clone

      members[member_name][index] = Hash.new
      pmembers = members[member_name][index]
      nested_member_names_now << member_name + "[#{index}]" # 配列用
      
      target_struct[:body]["contents"]["format"].each do |member|
        hmember = Hashie::Mash.new member
        nested_member_names_now2 = nested_member_names_now.clone # メンバ用
        # 最小構成
        next if get_value(nested_member_names_now2, hmember,         member_list, pmembers)
        # 構造体
        next if get_struct(nested_member_names_now2, yamls, hmember, member_list, pmembers)
        # TODO: ここに来たら異常フォーマット
      end
    end
  else
    # ただの構造体の場合
    raise "get_struct: does not exist type \"#{base_hmember.type}\" of Array." if !yamls[:structs].has_key?(base_hmember.type)
    target_struct = yamls[:structs][base_hmember.type]
    members[member_name] = Hash.new
    pmembers = members[member_name]
    nested_member_names << member_name
    target_struct[:body]["contents"]["format"].each do |member|
      hmember = Hashie::Mash.new member
      nested_member_names_now = nested_member_names.clone
      # 最小構成
      next if get_value(nested_member_names_now, hmember,         member_list, pmembers)
      # 構造体
      next if get_struct(nested_member_names_now, yamls, hmember, member_list, pmembers)
      # TODO: ここに来たら異常フォーマット
    end
  end
end

def set_value(format, key, value)
  # メンバが存在しているか確認
  if !member_name_include?(format[:member_list], key)
    binding.pry
    raise "set_value: member not found. \"#{key}\""
  end
  hmembers = format[:hmembers]
  begin
    type = eval "hmembers.#{key}.type"
    # TODO: サイズ内に収まってるか確認が必要
    if type == 'char'
      eval "hmembers.#{key}.value=\"#{value}\""
    else
      eval "hmembers.#{key}.value=#{value}"
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
      @member_total_size = 0 # memberのサイズ
      members = Hash.new # name_jp, type, value
      
      yaml[:body]["contents"]["format"].each do |member|
        hmember = Hashie::Mash.new member
        nested_member_names = Array.new
        # 最小構成
        next if get_value(nested_member_names, hmember,         member_list, members)
        # 構造体
        next if get_struct(nested_member_names, yamls, hmember, member_list, members)
        # TODO: ここに来たら異常フォーマット
      end
      # 出力設定
      formats[name] = Hash.new
      formats[name][:member_list] = member_list
      formats[name][:member_total_size] = @member_total_size
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


# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "hashie"
require "yaml_reader"

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

def get_value(member_names, hmember, member_list, members_name_jp, members_type, members_value)
  # 最小型ならそのまま保持
  if hmember.type.match(/int8|int16|int32|char/)
    member_name = hmember.name
    if m = member_name.match(/^(.+)\[([0-9]+)\]/)
      # 配列の場合
      member_name = m[1]
      members_value[member_name] = Array.new m[2].to_i, 0 # 初期値=0
      members_type[member_name] = hmember.type
      members_name_jp[member_name] = hmember.name_jp
    else
      # 配列でない場合
      members_value[member_name] = 0 # 初期値
      members_name_jp[member_name] = hmember.name_jp
      members_type[member_name] = hmember.type
    end
    # 名前登録
    member_names << member_name
    member_list << member_names.join(".")

    return true
  end
  return false
end

def get_struct_next(yamls, hmember, format, base)

end


#    :members_name_jp=>{"word"=>"ワード", "word_array"=>"ワード配列", "string"=>"文字列"},
#    :members_type=>{"word"=>"int16", "word_array"=>"int16", "string"=>"char"},
#    :members_value=>{"word"=>0, "word_array"=>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "string"=>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}}}
# 想定
#    :member_list=>["word_struct.b0", "word_struct.b1", "word_struct_array"=>[["b0","b1"],...],"string"],
#    :members_name_jp=>{"word_struct"=>{b0=>"b0",  b1=>"b1"   }, "word_struct_array"=>[ {b0=>{"b0", b1=>"b1"   },...], "string"=>"文字列"},
#    :members_type=>   {"word_struct"=>{b0=>"char",b1=>"int16"}, "word_struct_array"=>[ {b0=>"char",b1=>"int16"},.. ], "string"=>"char"},
#    :members_value=>  {"word_struct"=>{b0=>0     ,b1=>1      }, "word_struct_array"=>[ {b0=>0     ,b1=>1      },.. ], "string"=>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}}}

def get_struct(member_names, yamls, base_hmember, member_list, members_name_jp, members_type, members_value)
  member_name = base_hmember.name
  
  if m = member_name.match(/^(.+)\[([0-9]+)\]/)
    member_name = m[1]
    # 配列の場合
    members_name_jp[member_name] = Array.new(m[2].to_i)
    members_type[member_name] = Array.new(m[2].to_i)
    members_value[member_name] = Array.new(m[2].to_i)
    return false if !yamls[:structs].has_key?(base_hmember.type)
    target_struct = yamls[:structs][base_hmember.type]
    m[2].to_i.times do |index|
      member_names_now = member_names.clone

      members_name_jp[member_name][index] = Hash.new
      members_type[member_name][index] = Hash.new
      members_value[member_name][index] = Hash.new
      member_names_now << member_name + "[#{index}]" # 配列用
      
      target_struct[:body]["contents"]["format"].each do |member|
        hmember = Hashie::Mash.new member
        member_names_now2 = member_names_now.clone # メンバ用
        # 最小構成
        next if get_value(member_names_now2,         hmember, member_list, members_name_jp[member_name][index], members_type[member_name][index], members_value[member_name][index])
        # 構造体
        next if get_struct(member_names_now2, yamls, hmember, member_list, members_name_jp[member_name][index], members_type[member_name][index], members_value[member_name][index])
      end
    end
  else
    # ただの構造体の場合
    return false if !yamls[:structs].has_key?(base_hmember.type)
    target_struct = yamls[:structs][base_hmember.type]
    members_name_jp[member_name] = Hash.new
    members_type[member_name] = Hash.new
    members_value[member_name] = Hash.new

    member_names << member_name
    target_struct[:body]["contents"]["format"].each do |member|
      hmember = Hashie::Mash.new member
      member_names_now = member_names.clone
      # 最小構成
      next if get_value(member_names_now, hmember, member_list, members_name_jp[member_name], members_type[member_name], members_value[member_name])
      # 構造体
      next if get_struct(member_names_now, yamls, hmember, member_list, members_name_jp[member_name], members_type[member_name], members_value[member_name])
    end
  end
end

def get_format(yamls)
  formats = Hash.new
  
  yamls[:formats].each do |name,yaml|
    format = Hash.new
    format[:member_list] = Array.new # memberの順番
    format[:members_name_jp] = Hash.new # member別の日本語名
    format[:members_type] = Hash.new # member別のタイプ
    format[:members_value] = Hash.new # member別の値(初期値)

    # hformat = Hashie::Mash.new format
    
    yaml[:body]["contents"]["format"].each do |member|
      hmember = Hashie::Mash.new member
      member_names = Array.new
      # 最小構成
      next if get_value(member_names, hmember, format[:member_list], format[:members_name_jp], format[:members_type], format[:members_value])
      # 構造体
      next if get_struct(member_names, yamls, hmember, format[:member_list], format[:members_name_jp], format[:members_type], format[:members_value])

      # TODO: ここに来たら異常フォーマット
      # TODO: とりあえず読み飛ばし
    end
    
    hformat = Hashie::Mash.new format
    formats[name] = hformat
    
    # 初期値設定
    yaml[:body]["contents"]["default_values"].each do |default_value|
      type = eval "hformat.members_type.#{default_value[0]}"
      if type == 'char'
        eval "hformat.members_value.#{default_value[0]}=\"#{default_value[1]}\""
      else
        eval "hformat.members_value.#{default_value[0]}=#{default_value[1]}"
      end
    end
    binding.pry
    puts hformat
  end
  return formats
end

_yamls = YamlReader::get_yamls("yml")
yamls = remake_yamls(_yamls)
formats = get_format(yamls)
binding.pry

puts formats

# # test00 を表示
# puts "--- hash ---"
# puts yamls[:formats]["test00"][:body]["contents"]["format"]

# # Hashieで test00 を表示(symbolも同様にアクセスできる)
# h = Hashie::Mash.new yamls
# puts "--- hashie ---"
# puts h.formats.test00.body.contents.format



puts "終了"


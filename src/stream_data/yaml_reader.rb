# coding: utf-8

require 'find'
require 'yaml'

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module YamlReader
  EXTENSION_YAML  = '.yml'
  CONTENT_TYPE    = 'content-type'
  CONTENT_VERSION = 'content-version'
  CONTENTS        = 'contents'
  
  # 指定されたパスのYamlオブジェクトを取得する
  # path   : 取得するパス
  def get_yamls(path)
    yamls = Array.new
    
    # Yamlファイル一覧を取得
    files = get_files path, EXTENSION_YAML
    # Yamlファイル読込
    files.each do |file|
      body = read_yaml file
      yaml = Hash.new
      yaml[:file] = file
      yaml[:body] = body
      yamls << yaml
    end
    
    return yamls
  end
  
  # 指定されたパスのファイル一覧を取得する
  # path   : 取得するパス
  # extname: 拡張子
  def get_files(path, extension)
    files = Array.new
    Find.find( path ) do | f |
      if ( File.file?(f) ) then
        if ( File.extname( f ) == extension ) then
          files << f
        end
      end
    end
    return files
  end
  
  # YAMLファイル読込
  # filename: ファイル名
  def read_yaml(filename)
    body = nil
    begin
      File.open(filename) do |f|
        tmp = f.read
        body = YAML.load tmp
      end
    rescue => e
      raise "#{filename}: " + e.message
    end
    return body
  end
  
  # yamlsをnameをキーとしてHashにする
  # 指定typeのみを対象とする
  def yamls_by_name(yamls, type)
    hash = Hash.new
    yamls.each.with_index do |yaml,index|
      yaml_obj = yaml[:body]
      content_type = yaml_obj[CONTENT_TYPE]
      content_version = yaml_obj[CONTENT_VERSION]
      contents = yaml_obj[CONTENTS]
      raise "\"#{CONTENT_TYPE}\" is not defined: file=[#{yaml[:file]}]" if content_type.nil?
      raise "\"#{CONTENT_VERSION}\" is not defined: file=[#{yaml[:file]}]" if content_version.nil?
      raise "\"#{CONTENTS}\" is not defined: file=[#{yaml[:file]}]" if contents.nil?
      
      next unless content_type == type
      
      name = contents["name"]
      raise "\"name\" is not defined in \"#{CONTENTS}\": file=[#{yaml[:file]}]" if name.nil?
      if hash.has_key? name 
        Log.instance.warn "#{self.class}\##{__method__}: Multiple define name: type=[#{type}] name=[#{name}] file=[#{yaml[:file]}]"
        next
      end
      hash[name] = yaml
    end
    return hash
  end
  
end

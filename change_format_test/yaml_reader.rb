# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'find'
require 'yaml'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class YamlReader
  
  EXTENSION_YAML  = '.yml'
  
  # 指定されたパスのYamlオブジェクトを取得する
  # path   : 取得するパス
  def self.get_yamls(path)
    yamls = Array.new
    
    # Yamlファイル一覧を取得
    files = get_files(path, EXTENSION_YAML)
    # Yamlファイル読込
    files.each do |file|
      body = read_yaml(file)
      yaml = Hash.new
      yaml[:file] = file
      yaml[:body] = body
      yamls.push(yaml)
    end
    
    return yamls
  end
  
  # 指定されたパスのファイル一覧を取得する
  # path   : 取得するパス
  # extname: 拡張子
  def self.get_files(path, extension)
    files = Array.new
    Find.find( path ) do | f |
      if ( File.file?(f) ) then
        if ( File.extname( f ) == extension ) then
          files.push(f)
        end
      end
    end
    return files
  end
  
  # YAMLファイル読込
  # filename: ファイル名
  def self.read_yaml(filename)
    body = nil
    begin
      File.open(filename) do |f|
        tmp = f.read()
        body = YAML.load(tmp)
      end
    rescue => e
      raise "#{filename}: " + e.message
    end
    return body
  end
  
end
  

# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageData
  
  TARGET_CONTENT_TYPE    = 'STREAMDEBUGGER MESSAGE DATA'
  TARGET_CONTENT_VERSION = '0.1'
  
  NAME          = 'name'
  DESCRIPTION   = 'description'
  USING_FORMAT  = 'using_format'
  DATA          = 'data'
  VALUE         = 'value'
  
  attr_accessor :name
  attr_accessor :description
  attr_accessor :using_format
  attr_accessor :update_data
  
  # コンストラクタ
  def initialize(contents)
    create_contents(contents)
  end
  
  # コンテンツを生成
  def create_contents(contents)
    @name = contents[NAME]
    @description = contents[DESCRIPTION]
    @using_format = contents[USING_FORMAT]
    create_update_data(contents)
  end
  
  # 更新データを生成する
  def create_update_data(contents)
    @update_data = Array.new
    contents[DATA].each do |d|
      struct = Hash.new
      struct[NAME] = d[NAME]
      struct[VALUE] = d[VALUE]
      @update_data.push(struct)
    end
  end
  
end

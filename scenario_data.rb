# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class ScenarioData
  
  TARGET_CONTENT_TYPE    = 'STREAMDEBUGGER SCENARIO DATA'
  TARGET_CONTENT_VERSION = '0.1'
  
  NAME          = 'name'
  DESCRIPTION   = 'description'
  SEQUENCE      = 'sequence'
  COMMAND       = 'command'
  RESPONSE      = 'response'
  
  attr_accessor :name
  attr_accessor :description
  attr_accessor :sequences
  
  # コンストラクタ
  def initialize(contents)
    create_contents(contents)
  end
  
  # コンテンツを生成
  def create_contents(contents)
    @name = contents[NAME]
    @description = contents[DESCRIPTION]
    create_sequence(contents)
  end
  
  # シーケンスを生成する
  def create_sequence(contents)
    @sequences = Hash.new
    contents[SEQUENCE].each do |s|
      command = s[COMMAND]
      response = s[RESPONSE]
      if @sequences.has_key?(command)
        Log.instance.warn("#{self.class}##{__method__}: #{command} already exists.")
        next
      end
      @sequences[command] = response
    end
  end
  
  # 対象のコマンドかどうか
  def target?(command)
    return true if @sequences[command]
    return false
  end
  
  # レスポンスを取得する
  def get_response(command)
    return @sequences[command]
  end
  
end

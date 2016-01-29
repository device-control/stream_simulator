# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 待ち
class SequenceCommandSetVariable
  def initialize(arguments, messages)
    # # 変数設定
    # - command: :SET_VARIABLE
    #   arguments:
    #     name: :COUNTER # 変数名
    #     formula: "+="  # 式
    #     value: *size   # 値
    # 
    raise "not found :name" unless arguments.has_key? :name
    raise "not found :formula" unless arguments.has_key? :formula
    raise "not found :value" unless arguments.has_key? :value
    
    @arguments = arguments
    @variables = messages[:variables]
  end
  
  def run
    begin
      # 変数名が定義されてなければ、初期化する
      # 初期値:0
      @variables[@arguments[:name]] = 0 unless @variables.has_key? @arguments[:name]
      command = "@variables[:#{@arguments[:name]}] #{@arguments[:formula]} #{@arguments[:value]}"
      eval command
    rescue => e
      raise "unknown command [#{command}]\"#{e.message}\""
    end
  end
end


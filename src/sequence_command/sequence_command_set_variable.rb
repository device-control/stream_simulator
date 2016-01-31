# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 待ち
class SequenceCommandSetVariable
  def initialize(arguments, messages)
    raise "not found :name" unless arguments.has_key? :name
    raise "not found :command" unless arguments.has_key? :command
    
    @arguments = arguments
    @variables = messages[:variables]
  end
  
  def run
    Log.instance.debug "run command [SetVariable]"
    
    # :name = 変数名
    # :command = 実行コマンド
    #   :test = 1
    #   :test += 1
    # 変数名が定義されてなければ、初期化する。初期値:0
    begin
      @variables[@arguments[:name]] = 0 unless @variables.has_key? @arguments[:name]
      command = @arguments[:command]
      command = command.gsub(/\:[0-9a-zA-Z_]+/){|h|"@variables[#{h}]"}
      eval command
    rescue => e
      raise "unknown command [#{command}]\"#{e.message}\""
    end
  end
end


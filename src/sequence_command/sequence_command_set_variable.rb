# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'


# 待ち
class SequenceCommandSetVariable
  def initialize(arguments,variables)
    @arguments = arguments
    @variables = variables
  end
  
  def run
    # :name = 変数名
    # :command = 実行コマンド
    #   :test = 1
    #   :test += 1
    #   TODO: :testが未初期化の場合、どうするか検討が必要
    raise "not found name" unless @arguments.has_key? :name
    raise "not found command" unless @arguments.has_key? :command
    begin
      command = @arguments[:command]
      command.gsub!(/\:[0-9a-zA-Z_]+/){|h|"@variables[#{h}]"}
      eval command
    rescue => e
      raise "unknown command \"#{e.message}\""
    end
  end
end


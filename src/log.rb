# coding: utf-8

require 'singleton'
require 'logger'

# logger_level
# FATAL : プログラムで対処不可能なエラー
# ERROR : プログラムで対処可能なエラー
# WARN  : 警告
# INFO  : 一般的な情報
# DEBUG : 開発者向け情報
#
# output
# @log.fatal("fatal")
# @log.error("error")
# @log.warn("warn")
# @log.info("info")
# @log.debug("debug")
class Log
  include Singleton
  attr_reader :log
  
  def initialize
    disabled
  end
  
  def start(output, mode=Logger::DEBUG)
    output = STDOUT if output.nil?
    
    @log = Logger.new(output)
    @log.level = mode
    enabled
  end
  
  def enabled
    @show_enabled = true
  end
  
  def disabled
    @show_enabled = false
  end

  def method_missing(method, *args)
    return if @show_enabled == false
    begin
      @log.send method, args
    rescue => e
      puts "Log: error: " + e.message
    end
  end
end

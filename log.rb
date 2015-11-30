# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

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
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    # @log.level = Logger::ERROR
  end

  def method_missing(method, *args)
    begin
      @log.send method, args
    rescue => e
      puts "Log: error: " + e.message
    end
  end
end

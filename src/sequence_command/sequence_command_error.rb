# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# シーケンスコマンドエラー例外
class SequenceCommandError < StandardError
  attr_reader :position
  attr_reader :detail
  # message ... 例外のメッセージ
  # position ... 例外発生場所（scenario.sequence.command)
  # detail ... 例外の詳細（配列）
  def initialize(message,position,detail)
    super(message)
    raise "illegal parameter #{position} #{detail}" if position.nil? || detail.nil?
    @position = position
    @detail = detail
  end
end

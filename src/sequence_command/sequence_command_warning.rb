# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# シーケンスコマンドワーニング例外
class SequenceCommandWarning < StandardError
  attr_reader :detail
  # message ... 例外のメッセージ
  # detail ... 例外の詳細（配列）
  def initialize(message,detail)
    super(message)
    raise "illegal parameter #{detail}" if detail.nil?
    @detail = detail
  end
end

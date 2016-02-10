# coding: utf-8

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module SequenceCommandUtils
  # Integer()で変換できれば数値、例外発生したら違う
  def integer_string?(str)
    Integer(str)
    true
  rescue ArgumentError
    false
  end
  
  # Float()で変換できれば数値、例外発生したら違う
  def float_string?(str)
    Float(str)
    true
  rescue ArgumentError
    false
  end
end

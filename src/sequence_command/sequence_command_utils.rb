# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module SequenceCommandUtils
  
  # 更新するvaluesを取得する
  # 値がSymbolの場合、variablesから値を取得する
  def get_override_values(override_values, variables={})
    values = Hash.new
    override_values.each do |override_value|
      value = override_value[:value]
      if value.class == Symbol
        raise "#{self.class}\##{__method__} not found :#{value}" unless variables.has_key? value
        value = variables[value]
      end
      values[override_value[:name]] = value
    end
    return values
  end
  
end

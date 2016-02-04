# coding: utf-8

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module ExtendHash
  
  def symbolize_keys
    self.each_with_object({}){|(k,v),memo| memo[k.to_s.to_sym]=v}
  end
  
end

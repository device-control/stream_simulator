# coding: utf-8

require 'log'
require 'stream_data/autopilot'
require 'stream_data/extend_hash'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module AutopilotCreator
  
  # Autopilot 生成処理
  def create(name, yaml)
    begin
      raise "name is nil" if name.nil?
      raise "yaml is nil" if yaml.nil?
      raise "not found file" unless yaml.has_key? :file
      raise "not found body" unless yaml.has_key? :body
      raise "not found contents" unless yaml[:body].has_key? 'contents'
      raise "not found parameters" unless yaml[:body]['contents'].has_key? 'parameters'
      
      # parameters が対象かどうか
      target_parameters? yaml[:body]['contents']['parameters']
      
      # parameters のシンボル変換
      parameters = yaml[:body]['contents']['parameters']
      parameters.extend ExtendHash
      parameters = parameters.symbolize_keys
      
      # arguments のシンボル変換
      parameters[:arguments].each.with_index(0) do |argument, index|
        argument.extend ExtendHash
        parameters[:arguments][index] = argument.symbolize_keys
      end
      
      return Autopilot.new name, yaml[:file], parameters[:type], parameters[:arguments]
    rescue => e
      raise "#{e.message}\n file=[#{yaml[:file]}]"
    end
  end
  
  def target_parameters?(parameters)
    raise "parameters is nil" if parameters.nil?
    raise "not found type" unless parameters.has_key? 'type'
    raise "not found arguments" unless parameters.has_key? 'arguments'
    type = parameters['type']
    
    arguments = parameters['arguments']
    arguments.each do |argument|
      case type
      when :AUTO_RESPONSE
        raise "not found request_format" unless argument.has_key? 'request_format'
        raise "not found response_entity" unless argument.has_key? 'response_entity'
      when :INTERVAL_SEND
        raise "not found send_entity" unless argument.has_key? 'send_entity'
        raise "not found interval" unless argument.has_key? 'interval'
      else
        raise "undefined type [#{type}]"
      end
    end
  end
  
end

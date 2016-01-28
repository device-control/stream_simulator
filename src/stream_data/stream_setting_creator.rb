# coding: utf-8

require 'log'
require 'stream_data/stream_setting'
require 'stream_data/extend_hash'

module StreamSettingCreator
  
  # StreamSetting 生成処理
  def create(name, yaml)
    raise "name is nil" if name.nil?
    raise "yaml is nil" if yaml.nil?
    raise "not found file" unless yaml.has_key? :file
    raise "not found body" unless yaml.has_key? :body
    raise "not found contents" unless yaml[:body].has_key? 'contents'
    raise "not found parameters" unless yaml[:body]['contents'].has_key? 'parameters'
    
    parameters = yaml[:body]['contents']['parameters']
    target_parameters? parameters
    parameters.extend ExtendHash
    parameters = parameters.symbolize_keys
    
    return StreamSetting.new name, yaml[:file], parameters
  end
  
  def target_parameters?(parameters)
    raise "parameters is nil" if parameters.nil?
    raise "not found type in parameters" unless parameters.has_key? 'type'
    
    # type ごとのパラメータチェック
    case parameters['type']
    when :TCP_SERVER
      raise "not found name in parameters" unless parameters.has_key? 'name'
      raise "not found ip in parameters" unless parameters.has_key? 'ip'
      raise "not found port in parameters" unless parameters.has_key? 'port'
      # IPアドレス表記かどうか
      pattern = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
      raise "wrong ip address: [#{parameters['ip']}]" unless parameters['ip'] =~ pattern
    when :TCP_CLIENT
      raise "not found name in parameters" unless parameters.has_key? 'name'
      raise "not found ip in parameters" unless parameters.has_key? 'ip'
      raise "not found port in parameters" unless parameters.has_key? 'port'
      # IPアドレス表記かどうか
      pattern = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
      raise "wrong ip address: [#{parameters['ip']}]" unless parameters['ip'] =~ pattern
    else
      raise "undefined type: [#{type}]"
    end
  end
  
end

# coding: utf-8

require 'log'
require 'stream_data/stream_setting'
require 'stream_data/extend_hash'

module StreamSettingCreator
  
  # StreamSetting 生成処理
  def create(name, yaml)
    begin
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
    rescue => e
      raise "#{e.message}\n file=[#{yaml[:file]}]"
    end
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
    when :WEB_SOCKET_SERVER
      raise "not found name in parameters" unless parameters.has_key? 'name'
      raise "not found ip in parameters" unless parameters.has_key? 'ip'
      raise "not found port in parameters" unless parameters.has_key? 'port'
      # IPアドレス表記かどうか
      pattern = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
      raise "wrong ip address: [#{parameters['ip']}]" unless parameters['ip'] =~ pattern
    when :SERIAL
      raise "not found name in parameters" unless parameters.has_key? 'name'
      raise "not found port in parameters" unless parameters.has_key? 'port'
      raise "not found baud_rate in parameters" unless parameters.has_key? 'baud_rate'
      raise "not found data_bits in parameters" unless parameters.has_key? 'data_bits'
      raise "not found stop_bits in parameters" unless parameters.has_key? 'stop_bits'
      raise "not found parity in parameters" unless parameters.has_key? 'parity'
      # parity 設定値確認
      raise "wrong parity: [#{parameters['parity']}]" unless parameters['parity'] =~ /NONE|EVEN|ODD|MARK|SPACE/
    else
      raise "undefined type: [#{type}]"
    end
  end
  
end

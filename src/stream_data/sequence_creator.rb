# coding: utf-8

require 'log'
require 'sequence_command/sequence_command_creator'
require 'stream_data/sequence'
require 'stream_data/extend_hash'

require 'pry'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module SequenceCreator
  
  # Sequence 生成処理
  def create(name, yaml)
    begin
      raise "name is nil" if name.nil?
      raise "yaml is nil" if yaml.nil?
      raise "not found file" unless yaml.has_key? :file
      raise "not found body" unless yaml.has_key? :body
      raise "not found contents" unless yaml[:body].has_key? 'contents'
      raise "not found commands" unless yaml[:body]['contents'].has_key? 'commands'
      raise "commands not Array" unless yaml[:body]['contents']['commands'].instance_of? Array
      
      # commands のシンボル変換
      commands = Array.new
      yaml[:body]['contents']['commands'].each do |command|
        # command のシンボル変換
        command.extend ExtendHash
        command = command.symbolize_keys
        unless command[:arguments].nil?
          command[:arguments].extend ExtendHash
          command[:arguments] = command[:arguments].symbolize_keys
        end
        SequenceCommandCreator.command_permit? command # シンボルに変更後でないと呼び出せない
        commands << command
      end
      
      return Sequence.new name, yaml[:file], commands
    rescue => e
      raise "#{e.message}\n file=[#{yaml[:file]}]"
    end
  end
  
end

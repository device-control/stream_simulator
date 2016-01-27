# coding: utf-8

require 'log'
require 'stream_data/scenario'
# require 'stream_data/extend_hash'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module ScenarioCreator
  
  # Scenario 生成処理
  def create(name, yaml, sequences)
    raise "yaml is nil" if yaml.nil?
    raise "not found file" unless yaml.has_key? :file
    raise "not found body" unless yaml.has_key? :body
    raise "not found contents" unless yaml[:body].has_key? 'contents'
    raise "not found sequences" unless yaml[:body]['contents'].has_key? 'sequences'
    raise "sequences not Array" unless yaml[:body]['contents']['sequences'].instance_of? Array
    yaml_sequences = yaml[:body]['contents']['sequences']
    
    scenario_sequences = Array.new
    yaml_sequences.each do |sequence|
      raise "sequence is nil" if sequence.nil?
      
      raise "not found name" unless sequence.has_key? 'name'
      sequence_name = sequence['name']
      
      raise "not found sequence. [#{sequence_name}]" unless sequences.has_key? sequence_name
      scenario_sequences << sequences[sequence_name]
    end
    return Scenario.new name, yaml[:file], scenario_sequences
    
  end
  
end

# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット自動応答
class AutopilotAutoResponse
  def initialize(arguments, messages, stream, variables)
    @responses = create_responses(arguments,messages)
    @stream = stream
    @variables = variables
    @running = false
  end

  def create_responses(arguments, messages)
    responses = Hash.new
    # request_format: "03.04.02_Command"
    # response_entity: "03.04.02_ResponseData"
    arguments.each.with_index(0) do |_argument,index|
      argument = _argument.clone
      def argument.symbolize_keys
        self.each_with_object({}){|(k,v),memo| memo[k.to_s.to_sym]=v}
      end
      argument.symbolize_keys
      raise "arguments[#{index}] not found :request_format" unless argument.has_key? :request_format
      raise "arguments[#{index}] not found :response_entity" unless arguments.has_key? :response_entity
      raise "arguments[#{index}] unknown request_format name [#{argument[:request_format]}]" unless messages[:formats].has_key? argument[:request_format]
      raise "arguments[#{index}] unknown response_entity name [#{argument[:response_entity]}]" unless messages[:entities].has_key? argument[:response_entity]
      responses[argument[:request_format]] = messages[:entities][arguments[:response_entity]]
    end
    return responses
  end
  
  def start
    # 何もしない
    return false if @running
    return true
  end
  
  def stop
    # 何もしない
    return false if @running == false
    @running = false
    return true
  end

  # message entity 通知
  def message_entity_notify(message_entity)
    # 通知されてきたmessage_entityが応答リスト内に登録されているか
    unless @responses.has_key? message_entity.format
      # TODO: 登録されてない場合は、ログに出力する？
      return
    end
    @stream.write @responses[message_entity.format].encode
  end
  
end


# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット自動応答
class AutopilotAutoResponse
  def initialize(arguments, messages, stream)
    @arguments = arguments
    @messages = messages
    @stream = stream
    @responses = create_responses(@arguments)
    @running = false
  end

  def create_responses(arguments)
    responses = Hash.new
    # request_format: "03.04.02_Command"
    # response_entity: "03.04.02_ResponseData"
    arguments.each do |argument|
      responses[argument[:request_format]] = arguments[:respnse_entity]
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
    # 通知されてきたmessage_entityに対する応答を返す
    unless @responses.has_key? message_entity.name
      # TODO: ログだしする必要がある
      return
    end
    @stream.write @responses[message_entity.name].encode
  end
  
end


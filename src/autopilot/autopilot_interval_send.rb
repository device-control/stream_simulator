# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット
class AutopilotIntervalSendEntity
  def initialize(arguments, messages, stream)
    @arguments = arguments
    @messages = messages
    @stream = stream
    @interval_send_entities = create_interval_entities(@arguments)
    @running = false
  end

  # 8進数,10進数,16進数は考慮している
  # * -符号も対応
  # * 8進数は0始まり
  # * 16進数は0x始まり
  # * 小数点は未対応
  def integer?(str)
    Integer(str)
    true
  rescue ArgumentError
    false
  end
  
  def create_interval_entities(arguments)
    entities = Array.new
    arguments.each.with_index(0) do |argument,index|
      # エラーチェック
      raise "arguments[#{index}] not found send_entity" if argument.has_key :send_entity
      raise "arguments[#{index}] unknown send_entity name [#{argument[:send_entity]}]" if @messages[:entities].has_key? argument[:send_entity]
      raise "arguments[#{index}] unknown interval time [#{argument[:interval]}]" unless integer? argument[:interval]
      entity = Hash.new
      entity[:send_entity] = argument[:send_entity]
      entity[:interval] = argument[:interval]
      entity[:count] = 0
      entities << entity
    end
    return entities
  end
  
  def start
    return false if @running
    @thread = Thread.new(&method(:run))
    @running = true
    return true
  end

  def stop
    return false if @running == false
    @thread.kill
    @thread.join
    @thread = nil
    @running = false
    return true
  end

  private
  def run
    message_entities = message[:entities]
    loop do
      sleep 1
      @interval_send_entities.each do |ise|
        ise[:count] -= 1
        if ise[:count] <= 0
          @stream.write message_entities[ise[:send_entity]].encode
          ise[:count] = ise[:interval]
        end
      end
    end
  end

  # message entity 通知
  def message_entity_notify(message_entity)
    # 何もしない
  end
  
end


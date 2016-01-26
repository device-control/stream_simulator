# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット
class AutopilotIntervalSendEntity
  def initialize(arguments, messages, stream, variables)
    @interval_entities = create_interval_entities(arguments,messages)
    @stream = stream
    @variables = variables
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

  # インターバル送信するmessage_entityリストを生成する
  def create_interval_entities(arguments,messages)
    entities = Array.new
    arguments.each.with_index(0) do |_argument,index|
      argument = _argument.clone
      def argument.symbolize_keys
        self.each_with_object({}){|(k,v),memo| memo[k.to_s.to_sym]=v}
      end
      argument.symbolize_keys
      # エラーチェック
      raise "arguments[#{index}] not found :send_entity" unless argument.has_key :send_entity
      raise "arguments[#{index}] not found :interval" unless argument.has_key :interval
      raise "arguments[#{index}] unknown send_entity name [#{argument[:send_entity]}]" unless messages[:entities].has_key? argument[:send_entity]
      raise "arguments[#{index}] unknown interval time [#{argument[:interval]}]" unless integer? argument[:interval]
      entity = Hash.new
      entity[:send_entity] = messages[:entities][argument[:send_entity]]
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

  # message entity 通知
  def message_entity_notify(message_entity)
    # 何もしない
  end

  # 一秒間隔で送信できるか確認する
  private
  def run
    loop do
      sleep 1
      @interval_entities.each do |ise|
        ise[:count] -= 1
        if ise[:count] <= 0
          @stream.write ise[:send_entity].encode
          ise[:count] = ise[:interval]
        end
      end
    end
  end

  
end


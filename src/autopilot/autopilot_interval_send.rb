# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット
class AutopilotIntervalSend
  def initialize(arguments, messages, stream)
    @interval_entities = create_interval_entities(arguments,messages)
    @stream = stream
    @variables = messages[:variables]
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
  def create_interval_entities(arguments, messages)
    entities = Array.new
    arguments.each.with_index(0) do |argument, index|
      # エラーチェック
      raise "arguments[#{index}] not found :send_entity" unless argument.has_key? :send_entity
      raise "arguments[#{index}] not found :interval" unless argument.has_key? :interval
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
          send_entity = ise[:send_entity]
          output_send_entity send_entity
          @stream.write send_entity.encode @variables, :binary
          ise[:count] = ise[:interval]
        end
      end
    end
  end
  
  def output_send_entity(entity)
    Log.instance.debug "[IntervalSend] send: name=\"#{entity.name}\", message=\"#{entity.encode @variables}\""
    StreamLog.instance.lock
    StreamLog.instance.push :autopilot, "IntervalSend"
    StreamLog.instance.puts_member_list "send: name=\"#{entity.name}\", message=\"#{entity.encode @variables}\", member_list=", entity.get_all_members_with_values(@variables)
    StreamLog.instance.pop
    StreamLog.instance.unlock
  end
  
end


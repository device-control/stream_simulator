# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'
require 'stream/stream_setting'
require 'stream/stream_manager'
require 'stream_data/stream_data'
require 'stream_runner/stream_data_runner'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamSimulator
  
  attr_reader :stream
  attr_reader :stream_data
  attr_reader :stream_data_runner
  
  # コンストラクタ
  def initialize(inparam)
    # Log出力開始
    Log.instance.start inparam[:stream_simulator_log_path]
   
    # Stream生成
    stream_parameters = StreamSetting.load inparam[:stream_setting_file_path]
    @stream = StreamManager.create stream_parameters
    
    # StreamData生成
    @stream_data = StreamData.create inparam[:stream_data_path]
    
    # StreamDataRunner生成
    messages = Hash.new
    messages[:formats] = @stream_data.message_formats
    messages[:entities] = @stream_data.message_entities
    messages[:autopilot] = @stream_data.autopilots
    @stream_data_runner = StreamDataRunner.new @stream, messages
    
    # @stream.add_observer(StreamObserver::STATUS, self)
    # @stream.add_observer(StreamObserver::MESSAGE,self)
  end
  
  # 接続通知
  def stream_connected(stream)
    # Log.instance.debug "stream_coonected: " + stream.name
  end
  
  # 切断通知
  def stream_disconnected(stream)
    # Log.instance.debug "stream_discoonected: " + stream.name
  end
  
  # 受信通知
  def stream_message_received(stream, message)
    # Log.instance.debug message.bytes.collect{|ch|sprintf "%02X",ch.ord}.join
  end
  
  def run
    @stream_data.accept @stream_data_runner
  end
  
  def start
    @stream.open
    return true
  end
  
  def stop
    @stream.close
    return true
  end
  
  def write(message)
    @stream.write message
    return true
  end
  
  def show_message
    @stream_data.message_entities.each do |name, entity|
      puts "#{name}: #{entity.encode}"
    end
    return true
  end
  
  def show_message_format
    @stream_data.message_formats.each do |name, format|
      puts "#{name}: #{format.encode}"
    end
    return true
  end
  
end

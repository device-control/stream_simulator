# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'
require 'stream/stream_setting'
require 'stream/stream_manager'
require 'stream_data/stream_data_creator'

require 'stream_data_runner'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamSimulator
  
  attr_reader :stream
  attr_reader :stream_data
  attr_reader :message_analyze
  
  # コンストラクタ
  def initialize(inparam)
    # Log出力開始
    Log.instance.start inparam[:log_output_destination]
   
    # Stream生成
    stream_parameters = StreamSetting.load inparam[:stream_setting_file_path]
    @stream = StreamManager.create stream_parameters
    
    # StreamData生成
    stream_data_creator = StreamDataCreator.new inparam[:stream_data_path]
    @stream_data = stream_data_creator.create
    
    # StreamDataRunner生成
    messages = Hash.new
    messages[:formats] = @stream_data.message_formats
    messages[:entities] = @stream_data.message_entities
    @stream_data_runner = StreamDataRunner.new @stream, messages
    
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

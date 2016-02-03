# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'
require 'fileutils'
require 'stream/stream_manager'
require 'stream_runner/stream_data_runner'
require 'stream_data/stream_data'
require 'stream_data/message_utils'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamSimulator
  include MessageUtils
  
  attr_reader :inparam
  attr_reader :stream
  attr_reader :stream_data
  attr_reader :stream_data_runner
  
  # コンストラクタ
  def initialize(inparam)
    raise "inparam is nil" if inparam.nil?
    raise "not found :stream_data_path" unless inparam.has_key? :stream_data_path
    raise "not found :stream_setting_name" unless inparam.has_key? :stream_setting_name
    raise "not found :stream_log_path" unless inparam.has_key? :stream_log_path
    
    # 入力パラメータ
    @inparam = inparam
    
    # StreamLog出力先を作成
    FileUtils.mkdir_p(inparam[:stream_log_path]) unless FileTest.exist?(inparam[:stream_log_path])
    
    # Log出力開始
    Log.instance.start inparam[:debug_log_path]
    
    # StreamData生成
    @stream_data = StreamData.create inparam[:stream_data_path]
    
    # Stream生成
    stream_setting_name = inparam[:stream_setting_name]
    raise "not found stream_setting_name: [#{stream_setting_name}]" unless @stream_data.stream_settings.has_key? stream_setting_name
    @stream = StreamManager.create @stream_data.stream_settings[stream_setting_name].parameters
    
    # StreamDataRunner生成
    messages = Hash.new
    messages[:formats] = @stream_data.message_formats
    messages[:entities] = @stream_data.message_entities
    messages[:autopilots] = @stream_data.autopilots
    messages[:variables] = @stream_data.variables
    @stream_data_runner = StreamDataRunner.new @stream, messages
    
  end
  
  # シナリオ実行
  def run(scenario_list)
    ret = false
    scenario_list.each do |scenario_name|
      begin
        unless @stream_data.scenarios.has_key? scenario_name
          Log.instance.debug "scenario not found: name=[#{scenario_name}]"
          return false
        end
        @stream_data.accept @stream_data_runner, scenario_name
        ret = true
      rescue => e
        StreamLog.instance.puts "ERROR: message=\"#{e.message}\""
        StreamLog.instance.puts "ERROR: backtrace=\n#{e.backtrace.join("\n")}\n"
      ensure
        StreamLog.instance.write_dos make_stream_log_filename scenario_name
      end
    end
    return ret
  end
  
  # ストリームログファイル名を生成
  def make_stream_log_filename(filename)
    # Windowsでファイル名に使用できない文字を'_'に置換する
    filename = filename.gsub(/:|;|>|<|"|\/|\?|\\|\*|\|/, '_')
    return @inparam[:stream_log_path]+"/#{filename}.log"
  end
  
  # stream 開始
  def start
    @stream.open
    return true
  end
  
  # stream 停止
  def stop
    @stream.close
    return true
  end
  
  # メッセージ送信
  def write(message)
    hex_string = binary_to_hex_string message
    @stream.write hex_string
    return true
  end
  
  # メッセージ一覧表示
  def show_message
    @stream_data.message_entities.each do |name, entity|
      puts "#{name}: \"#{entity.encode @stream_data.variables}\""
    end
    return true
  end
  
  # メッセージフォーマット一覧表示
  def show_message_format
    @stream_data.message_formats.each do |name, format|
      puts "#{name}: \"#{format.encode @stream_data.variables}\""
    end
    return true
  end
  
  # シナリオ一覧表示
  def show_scenario
    @stream_data.scenarios.each do |name, scenario|
      puts "#{name}: \"#{scenario.name}\""
    end
    return true
  end
  
  # メンバーリスト一覧表示
  def show_member_list(format_name)
    puts "member_list: "
    @stream_data.message_formats[format_name].member_list.each do |member_name|
      puts "\"#{member_name}\""
    end
    return true
  end
  
end

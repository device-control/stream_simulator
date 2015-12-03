# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MessageObject
  
  NAME          = 'name'
  VALUE         = 'value'
  
  attr_accessor :name
  attr_accessor :format
  attr_accessor :data
  
  # コンストラクタ
  def initialize(name, format, data)
    @name = name
    @format = format
    create_data(data)
  end
  
  # データを生成
  def create_data(data)
    @data = Array.new
    data.each do |d|
      struct = Hash.new
      struct[NAME] = d[NAME]
      struct[VALUE] = d[VALUE]
      @data.push(struct)
    end
  end
  
  # データ更新
  def update_data(update_data)
    return if update_data.nil?
    
    update_data.each do |u|
      @data.each do |d|
        if d[NAME] == u[NAME]
          d[VALUE] = u[VALUE]
        end
      end
    end
  end
  
  # エンコード処理
  def encode
    return @format.encode(@data)
  end
  
  # バイナリテキスト変換
  def to_hex_string
    binary_data = encode()
    return @format.convert_hex_string(binary_data)
  end
  
  # データをログに出力する
  def to_log
    log = Log.instance
    log.info "name = #{@name}"
    @data.each do |d|
      log.info "#{d[NAME]} = #{d[VALUE]}"
    end
  end
  
end

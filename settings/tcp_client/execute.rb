# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require '../../stream_simulator'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

path = File.expand_path(File.dirname(__FILE__))

#---------------------------------------------------
# [環境設定]
# stream_setting_file : ストリームの設定ファイル
# testdata_path       : 使用するテストデータのパス
#---------------------------------------------------
stream_setting_file = 'stream_setting.yml'
testdata_path       = 'test_data'

# パラメータ設定
$inparam = Hash.new
$inparam[:stream_setting_file_path] = path+'/'+stream_setting_file
$inparam[:testdata_path] = path+'/'+testdata_path
# シミュレータ生成
$simulator = StreamSimulator.new $inparam

#---------------------------------------------------
# [コマンド定義]
# 使用したいコマンドを定義してください
#---------------------------------------------------
# 開始
def start
  $simulator.start
end

# 停止
def stop
  $simulator.stop
end

# バイナリテキストをバイナリに変換し、メッセージを送信する
def write(message)
  binary_message = message.scan(/.{2}/).collect{|c| c.hex}.pack("C*")
  $simulator.write binary_message
end

def show_message
  $simulator.show_message
end

# coding: utf-8
# 実行サンプルスクリプト(execute_stream_simulator.rb)
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

#---------------------------------------------------
# (1) 配置した StreamSimulator ディレクトリ位置を指定
#  本スクリプトの配置位置からの相対パスを指定する必要がある
#  例：stream_simulator_path = '../../stream_simulator/stream_simulator'
require '../../../../stream_simulator/src/stream_simulator'


Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

#---------------------------------------------------
# (2) StreamSimulator データ一式の位置を指定
#  本スクリプトの配置位置からの相対パスを指定する必要がある
#  例：simulator_data_path = 'simulator_data'
simulator_data_path = '../stream_data'


#---------------------------------------------------
# (3) StreamSimulator Stream設定ファイルの位置を指定
#  本スクリプトの配置位置からの相対パスを指定する必要がある
#  例：stream_setting_file = 'stream_setting.yml'
stream_setting_file = '../stream_data/settings/tcp_client_setting.yml'


# パラメータ設定
$inparam = Hash.new
$inparam[:stream_setting_file_path] = File.expand_path(File.dirname(__FILE__))+"/#{stream_setting_file}"
$inparam[:stream_data_path] = File.expand_path(File.dirname(__FILE__))+"/#{simulator_data_path}"
$inparam[:stream_simulator_log_path] = File.expand_path(File.dirname(__FILE__))+"/stream_simulator.log"
# シミュレータ生成
$simulator = StreamSimulator.new $inparam

# 既定のコマンド定義

# シナリオ実行
def run(scenario_name)
  $simulator.run scenario_name
end


#---------------------------------------------------
# (4) 使用したいコマンドを追加
#  stream_simulator のメソッド呼び出しを追加することが可能
#  以下サンプルコマンドを追加

# 開始
def start
  $simulator.start
end

# 停止
def stop
  $simulator.stop
end

# メッセージを送信する
def write(message)
  $simulator.write message
end

# 管理しているメッセージをバイナリテキストにして表示する
def show_message
  $simulator.show_message
end

# 管理しているメッセージフォーマットをバイナリテキストにして表示する
def show_message_format
  $simulator.show_message_format
end

# 管理しているシナリオを表示する
def show_scenario
  $simulator.show_scenario
end

# 本スクリプト実行時に開始コマンドを実行する
run "tcp_client_scenario"


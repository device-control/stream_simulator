# coding: utf-8
# 実行サンプルスクリプト(execute_stream_simulator.rb)
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

#---------------------------------------------------
# (1) 配置した StreamSimulator ディレクトリ位置を指定
#  本スクリプトの配置位置からの相対パスを指定する必要がある
#  例：stream_simulator_path = '../../stream_simulator/src/stream_simulator'
require '../../../src/stream_simulator'

#---------------------------------------------------
# (2) StreamSimulator データ一式の位置を指定
#  本スクリプトの配置位置からの相対パスを指定する必要がある
#  例：simulator_data_path = '../stream_data'
simulator_data_path = '../stream_data'

#---------------------------------------------------
# (3) StreamSimulator 使用するStream名を設定
#  StreamSimulator データに含まれているstream名を設定する必要がある
#  例：stream_setting_name = 'stream_setting'
stream_setting_name = 'websocket_server_setting'
execute_function_receiver_name = nil

#---------------------------------------------------
# (4) StreamSimulator ログの出力先を指定
#  StreamSimulator のログ出力先を指定する必要がある
#  例：stream_log_path = './log'
stream_log_path = './log'

#---------------------------------------------------
# (5) 起動時に実行するシナリオを追加
#  本スクリプト起動時に実行するシナリオを指定する
#  例：scenario_list = [
#        "tcp_server_scenario",
#      ]
scenario_list = [
  "websocket_server_scenario",
]


# パラメータ設定
$inparam = Hash.new
$inparam[:stream_data_path] = File.expand_path(File.dirname(__FILE__))+"/#{simulator_data_path}"
$inparam[:stream_setting_name] = stream_setting_name
$inparam[:execute_function_receiver_name] = execute_function_receiver_name
# ストリームログ出力PATHを設定
$inparam[:stream_log_path] = File.expand_path(File.dirname(__FILE__))+"/#{stream_log_path}"
# デバッグログ出力先
$inparam[:debug_log_path] = File.expand_path(File.dirname(__FILE__))+"/stream_simulator.log"
# シミュレータ生成
$simulator = StreamSimulator.new $inparam

# 既定のコマンド定義

# シナリオ実行
def run(scenario_list)
  $simulator.run scenario_list
end


#---------------------------------------------------
# (6) 使用したいコマンドを追加
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

def external_command(command_name,autopilot_name)
  # # 自動応答開始
  # - name: :AUTOPILOT_START
  #   arguments:
  #     name: "autopilot_auto_response"
  # # 自動応答終了
  # - name: :AUTOPILOT_END
  #   arguments:
  #     name: "autopilot_auto_response"
  command = {
    :name => command_name,
    :arguments => {
      :name => autopilot_name,
    }
  }
  $simulator.stream_data_runner.external_command(command)
end

puts "Start StreamSimulator..."
#  本スクリプト実行時にシナリオを実行する
run scenario_list


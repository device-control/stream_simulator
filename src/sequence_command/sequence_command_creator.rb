# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'
require 'sequence_command_send'
require 'sequence_command_receive'
require 'sequence_command_wait'
require 'sequence_command_set_variable'
require 'sequence_command_autopilot_start'
require 'sequence_command_autopilot_end'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# シーケンスコマンド生成
class SequenceCommandCreator
  def self.create(sequence, messages, stream, queues, variables)
    if sequence[:command] == :OPEN # ストリーム開始
      return SequenceCommandOpen.new stream
    elsif sequence[:command] == :SEND # メッセージ送信
      return SequenceCommandSend.new sequence[:arguments], messages, stream
    elsif sequence[:command] == :RECEIVE # メッセージ受信
      return SequenceCommandReceive.new sequence[:arguments], messages, stream, queues[:sequence]
    elsif sequence[:command] == :WAIT # 待ち
      return SequenceCommandWait.new sequence[:arguments]
    elsif sequence[:command] == :SET_VARIABLE # 変数設定
      return SequenceCommandSetVariable.new sequence[:arguments], variables
    elsif sequence[:command] == :AUTOPILOT_START # オートパイロット開始
      return SequenceCommandAutopilotStart.new sequence[:arguments], messages, stream, queues[:autopilot], variables
    elsif sequence[:command] == :AUTOPILOT_END # オートパイロット終了
      return SequenceCommandAutopilotEnd.new sequence[:arguments]
    elsif sequence[:command] == :CLOSE # ストリーム終了
      return SequenceCommandClose.new stream
    else
      raise "unknonw command [#{sequence[:command]}]"
    end
  end
end


# 例外発行場所出力サンプル(backtrace)
# class TestCreator
#   def self.create
#     raise "test"
#   end
# end

# class Test
#   def run
#     begin
#       t = TestCreator.create
#     rescue => e
#       puts e.backtrace.join("\n")
#       puts "message:" + e.message
#     end
#   end
# end


# coding: utf-8

require 'log'
require 'sequence_command/sequence_command_open'
require 'sequence_command/sequence_command_close'
require 'sequence_command/sequence_command_send'
require 'sequence_command/sequence_command_receive'
require 'sequence_command/sequence_command_wait'
require 'sequence_command/sequence_command_set_variable'
require 'sequence_command/sequence_command_autopilot_start'
require 'sequence_command/sequence_command_autopilot_end'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# シーケンスコマンド生成
class SequenceCommandCreator
  def self.create(command, messages, stream, queues)
    raise "not found :name" unless command.has_key? :name
    raise "not found :arguments" unless command.has_key? :arguments
    arguments = command[:arguments]
    
    case command[:name]
    when :OPEN # ストリーム開始
      return SequenceCommandOpen.new stream
    when :SEND # メッセージ送信
      return SequenceCommandSend.new arguments, messages, stream
    when :RECEIVE # メッセージ受信
      return SequenceCommandReceive.new arguments, messages, stream, queues[:sequence]
    when :WAIT # 待ち
      return SequenceCommandWait.new arguments
    when :SET_VARIABLE # 変数設定
      return SequenceCommandSetVariable.new arguments, messages
    when :AUTOPILOT_START # オートパイロット開始
      return SequenceCommandAutopilotStart.new arguments, messages, stream
    when :AUTOPILOT_END # オートパイロット終了
      return SequenceCommandAutopilotEnd.new arguments
    when :CLOSE # ストリーム終了
      return SequenceCommandClose.new stream
    else
      raise "unknonw command [#{command[:name]}]"
    end
  end
end


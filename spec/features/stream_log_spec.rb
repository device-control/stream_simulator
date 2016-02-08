# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../src'))

require 'stream_log'
require 'log'
require 'pry'

describe 'StreamLog' do
  log = Log.instance
  log.disabled
  stream_log = StreamLog.instance
  
  before :all do
    
  end

  after :all do
    File.unlink "test.log" if File.exist? "test.log"
  end
  
  context 'get_position/push,pop' do
    it '未登録ならnilになること' do
      # 未登録
      expect(stream_log.get_position).to eq ""
    end
    it '登録できること' do
      # 登録
      expect{stream_log.push :scenario, "scenario"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.push :sequence, "sequence"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.push :command, "command"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence.command"
    end
    it '削除できること' do
      # 削除
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq ""
    end
  end

  context 'reset' do
    it '動作位置名が破棄されていること' do
      # 登録
      expect{stream_log.push :scenario, "scenario"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.push :sequence, "sequence"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.push :command, "command"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence.command"
      # リセット
      expect{stream_log.reset}.not_to raise_error
      expect(stream_log.get_position).to eq ""
    end
  end

  context 'puts/puts_message/puts_error/puts_warning' do
    it 'OKパターン：正しくメッセージが記録されていること' do
      # リセット
      expect{stream_log.reset}.not_to raise_error
      # 登録
      expect{stream_log.push :scenario, "scenario"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.push :sequence, "sequence"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.push :command, "command"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence.command"
      # ログ出力なし(OK)
      # 削除
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq ""
      # # 書き出し
      expect{stream_log.write_dos "test.log"}.not_to raise_error

      expected_logs = <<-'EXPECTED_LOGS'
[OK]
[LOGS]
->scenario[scenario]
  position: scenario
->  sequence[sequence]
    position: scenario.sequence
->    command[command]
      position: scenario.sequence.command
<-    command[command]
<-  sequence[sequence]
<-scenario[scenario]
      EXPECTED_LOGS
      expected_logs.sub!(/\n$/m,'') # 最後の改行を削除
      actual_logs = File.read("test.log").encode('utf-8')
      expect( actual_logs ).to eq expected_logs
    end
    
    it 'ERRORのみ発生パターン：正しくメッセージが記録されていること' do
      # リセット
      expect{stream_log.reset}.not_to raise_error
      # 登録
      expect{stream_log.push :scenario, "scenario"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.push :sequence, "sequence"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.push :command, "command"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence.command"
      # ログ出力
      expect{stream_log.puts_error "puts_error", ["error_detail1","error_detail2"] }.not_to raise_error
      # 削除
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq ""
      # # 書き出し
      expect{stream_log.write_dos "test.log"}.not_to raise_error

      expected_logs = <<-'EXPECTED_LOGS'
[ERROR]
 position: scenario.sequence.command
 message: puts_error
  error_detail1
  error_detail2
[LOGS]
->scenario[scenario]
  position: scenario
->  sequence[sequence]
    position: scenario.sequence
->    command[command]
      position: scenario.sequence.command
<-    command[command]
<-  sequence[sequence]
<-scenario[scenario]
      EXPECTED_LOGS
      expected_logs.sub!(/\n$/m,'') # 最後の改行を削除
      actual_logs = File.read("test.log").encode('utf-8')
      expect( actual_logs ).to eq expected_logs
    end

    it 'WARNINGのみ発生パターン：正しくメッセージが記録されていること' do
      # リセット
      expect{stream_log.reset}.not_to raise_error
      # 登録
      expect{stream_log.push :scenario, "scenario"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.push :sequence, "sequence"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.push :command, "command"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence.command"
      # ログ出力
      expect{stream_log.puts_warning "puts_warning1", ["warning1_detail1","warning1_detail2"]}.not_to raise_error
      expect{stream_log.puts_warning "puts_warning2", ["warning2_detail1","warning2_detail2"]}.not_to raise_error
      # 削除
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq ""
      # # 書き出し
      expect{stream_log.write_dos "test.log"}.not_to raise_error

      expected_logs = <<-'EXPECTED_LOGS'
[OK]
[WARNING] 2
 1:
 position: scenario.sequence.command
 message: puts_warning1
  warning1_detail1
  warning1_detail2
 2:
 position: scenario.sequence.command
 message: puts_warning2
  warning2_detail1
  warning2_detail2
[LOGS]
->scenario[scenario]
  position: scenario
->  sequence[sequence]
    position: scenario.sequence
->    command[command]
      position: scenario.sequence.command
<-    command[command]
<-  sequence[sequence]
<-scenario[scenario]
      EXPECTED_LOGS
      expected_logs.sub!(/\n$/m,'') # 最後の改行を削除
      actual_logs = File.read("test.log").encode('utf-8')
      expect( actual_logs ).to eq expected_logs
    end

    
    it 'ERROR+WARNING発生パターン：正しくメッセージが記録されていること' do
      # リセット
      expect{stream_log.reset}.not_to raise_error
      # 登録
      expect{stream_log.push :scenario, "scenario"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.push :sequence, "sequence"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.push :command, "command"}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence.command"
      # ログ出力
      expect{stream_log.puts_error "puts_error", ["error_detail1","error_detail2"] }.not_to raise_error
      expect{stream_log.puts_warning "puts_warning1", ["warning1_detail1","warning1_detail2"]}.not_to raise_error
      expect{stream_log.puts_warning "puts_warning2", ["warning2_detail1","warning2_detail2"]}.not_to raise_error
      # 削除
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario.sequence"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq "scenario"
      expect{stream_log.pop}.not_to raise_error
      expect(stream_log.get_position).to eq ""
      # # 書き出し
      expect{stream_log.write_dos "test.log"}.not_to raise_error

      expected_logs = <<-'EXPECTED_LOGS'
[ERROR]
 position: scenario.sequence.command
 message: puts_error
  error_detail1
  error_detail2
[WARNING] 2
 1:
 position: scenario.sequence.command
 message: puts_warning1
  warning1_detail1
  warning1_detail2
 2:
 position: scenario.sequence.command
 message: puts_warning2
  warning2_detail1
  warning2_detail2
[LOGS]
->scenario[scenario]
  position: scenario
->  sequence[sequence]
    position: scenario.sequence
->    command[command]
      position: scenario.sequence.command
<-    command[command]
<-  sequence[sequence]
<-scenario[scenario]
      EXPECTED_LOGS
      expected_logs.sub!(/\n$/m,'') # 最後の改行を削除
      actual_logs = File.read("test.log").encode('utf-8')
      expect( actual_logs ).to eq expected_logs
    end

  end
end


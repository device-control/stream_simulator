# coding: utf-8
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/..'))
$LOAD_PATH.push(File.expand_path(File.dirname(__FILE__)+'/../../../src'))

require 'stream/stream_serial'
require 'stream/stream_observer'
require 'log'

require 'pry'

class MockListener
  attr_reader :name, :connects, :recv_messages, :recv_message
  
  def initialize(name)
    @name = name
    @connects = 0
    @recv_messages = 0
    @recv_message = nil
  end
  
  # 接続通知
  def stream_connected(stream)
    # COM3,COM4がオープンしてきた時
    @connects += 1
  end

  # 切断通知
  def stream_disconnected(stream)
    # COM3,COM4がクローズしたとき
    @connects -= 1
  end

  # 受信通知
  def stream_message_received(stream,message)
    # COM3,COM4からメッセージを受信してきた時
    @recv_messages += 1
    @recv_message = message
  end
end


describe 'StreamSerial' do
  before do
    log = Log.instance
    log.disabled
  end
  
  context '生成' do
    # before do
    #   @serial = StreamSerial.new 'serial', 'COM3', 115200, 8, 1, SerialPort::NONE
    # end
    it '正しく生成されることを確認' do
      serial = StreamSerial.new 'serial', 'COM3', 115200, 8, 1, 'NONE'
      expect(serial.name).to eq 'serial'
      expect(serial.port).to eq 'COM3'
      expect(serial.baud_rate).to eq 115200
      expect(serial.data_bits).to eq 8
      expect(serial.stop_bits).to eq 1
      expect(serial.parity).to eq SerialPort::NONE # 内部的にはserialport値に変換されている
      serial.close
    end
  end

  context 'オープン' do
    it 'クライアントが接続できるか確認' do
      listener3 = MockListener.new 'COM3'
      listener4 = MockListener.new 'COM4'
      
      serial3 = StreamSerial.new 'serial3', 'COM3', 115200, 8, 1, 'NONE'
      serial4 = StreamSerial.new 'serial4', 'COM4', 115200, 8, 1, 'NONE'

      serial3.add_observer StreamObserver::STATUS, listener3
      serial3.add_observer StreamObserver::MESSAGE, listener3
      serial4.add_observer StreamObserver::STATUS, listener4
      serial4.add_observer StreamObserver::MESSAGE, listener4

      expect{serial3.open}.not_to raise_error # expect がブロック呼び出しになっていることに注意
      expect{serial4.open}.not_to raise_error
      
      # オープン待ち(max 5sec)
      5.times do
        break if listener3.connects != 0 && listener4.connects != 0
        sleep 1
      end
      expect(listener3.connects).to eq 1
      expect(listener4.connects).to eq 1
      serial3.close
      serial4.close
    end

    it '２重にオープンしてもエラーとならないことを確認' do
      listener3 = MockListener.new 'COM3'
      listener4 = MockListener.new 'COM4'
      
      serial3 = StreamSerial.new 'serial', 'COM3', 115200, 8, 1, 'NONE'
      serial4 = StreamSerial.new 'serial', 'COM4', 115200, 8, 1, 'NONE'
      
      serial3.add_observer StreamObserver::STATUS,  listener3
      serial3.add_observer StreamObserver::MESSAGE, listener3
      serial4.add_observer StreamObserver::STATUS,  listener4
      serial4.add_observer StreamObserver::MESSAGE, listener4

      # １回目のオープン
      expect{serial3.open}.not_to raise_error
      expect{serial4.open}.not_to raise_error

      # ２回目のオープン
      expect{serial3.open}.not_to raise_error
      expect{serial4.open}.not_to raise_error

      # オープン待ち(max 5sec)
      5.times do
        break if listener3.connects != 0 && listener4.connects != 0
        sleep 1
      end
      expect(listener3.connects).to eq 1
      expect(listener4.connects).to eq 1
      serial3.close
      serial4.close
    end

  end

  context '送信'  do
    it 'COM3/COM4でメッセージ送信できることを確認' do
      listener3 = MockListener.new 'COM3'
      listener4 = MockListener.new 'COM4'
      
      serial3 = StreamSerial.new 'serial', 'COM3', 115200, 8, 1, 'NONE'
      serial4 = StreamSerial.new 'serial', 'COM4', 115200, 8, 1, 'NONE'
      
      serial3.add_observer StreamObserver::STATUS,  listener3
      serial3.add_observer StreamObserver::MESSAGE, listener3
      serial4.add_observer StreamObserver::STATUS,  listener4
      serial4.add_observer StreamObserver::MESSAGE, listener4

      expect{serial3.open}.not_to raise_error
      expect{serial4.open}.not_to raise_error
      # オープン待ち(max 5sec)
      5.times do
        break if listener3.connects != 0 && listener4.connects != 0
        sleep 1
      end
      expect(listener3.connects).to eq 1
      expect(listener4.connects).to eq 1

      expect{ serial3.write "COM3 to COM4" }.not_to raise_error
      expect{ serial4.write "COM4 to COM3" }.not_to raise_error
      # ライト待ち(max 5sec)
      5.times do
        break if listener3.recv_messages != 0 && listener4.recv_messages != 0
        sleep 1
      end

      expect(listener3.recv_messages).to eq 1
      expect(listener3.recv_message).to eq 'COM4 to COM3'
      expect(listener4.recv_messages).to eq 1
      expect(listener4.recv_message).to eq 'COM3 to COM4'
      
      serial3.close
      serial4.close
    end
  end

end

# coding: utf-8

require 'serialport'
require "stream/stream_observer"
require "log"

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class StreamSerial
  include StreamObserver
  attr_reader :name, :port, :baud_rate, :data_bits, :stop_bits, :parity
  
  def initialize(name, port, baud_rate, data_bits, stop_bits, parity)
    super()
    @name = name
    @port = port
    @baud_rate = baud_rate
    @data_bits = data_bits
    @stop_bits = stop_bits
    # TODO: 仕方がないのでここで外部との依存を切る
    if( parity == 'NONE')
      @parity = SerialPort::NONE
    elsif (parity == 'EVEN')
      @parity = SerialPort::EVEN
    elsif (parity == 'ODD')
      @parity = SerialPort::ODD
    elsif (parity == 'MARK')
      @parity = SerialPort::MARK
    elsif (parity == 'SPACE')
      @parity = SerialPort::SPACE
    else
      raise "StreamSerial::initialize: error"
    end
    @opened = false
    @locker = Mutex::new
    @serial = nil
  end

  def open
    return if @opened
    log = Log.instance
    @locker.lock
    begin
      # @serial = SerialPort.open(@port, 115200, 8, 1, SerialPort::NONE)
      @serial = SerialPort.open(@port, @baud_rate, @data_bits, @stop_bits, @parity)
      @serial.read_timeout = -1 # 5 * 1000 # 0=受信されるまで無限待ち, 1>=待ち時間(ms)
      @thread = Thread.new(&method(:receive))
      @opened = true
      notify_connect # オープン通知
    rescue => e
      @serial.close if @serial
      @serial = nil
      raise "StreamSerial::open: error: "+e.message
    ensure
      log.debug "StreamSerial#open: ensure"
      @locker.unlock
    end
  end

  def write(message)
    @locker.synchronize do
      @serial.write message
    end
  end

  def close
    return false if !@opened
    @locker.synchronize do
      @thread.kill # 無理クリ終了
      @thread.join
      @thread = nil
      @serial.close if @serial
      @opened = false
      notify_disconnect # クローズ通知
    end
  end

  private
  # 受信
  def receive
    log = Log.instance
    log.debug "StreamSerial#receive #{@port}: receiveing..."
    begin
      loop do
        sleep 0.05
        recv = @serial.read
        next if( 0 == recv.size )
        # 受信内容表示
        # $messages.push recv.clone
        log.debug "StreamSerial#receive #{@port}: received: " + recv.unpack("H*").to_s + "\n"
        notify_message recv # 受信通知
      end
    rescue => e
      log.error "StreamSerial#receive: rescue: "+e.message
    ensure
      log.debug "StreamSerial#receive: ensure"
      @serial.close if @serial
      @serial = nil
      @opened = false
    end
    log.debug "StreamSerial#receive #{@port} end"
  end
  
end


# coding: utf-8

require "stream/stream_tcp_server"
require "stream/stream_tcp_client"
require "stream/stream_websocket_server"
require "stream/stream_serial"

class StreamManager
  def self.create(parameters)
    stream = nil
    begin
      raise "parameters is nil" if parameters.nil?
      raise "not found :name" unless parameters.has_key? :name
      
      if parameters[:type] == :TCP_SERVER
        raise "not found :type" unless parameters.has_key? :type
        raise "not found :ip" unless parameters.has_key? :ip
        raise "not found :port" unless parameters.has_key? :port
        stream = StreamTCPServer.new( parameters[:name],
                                      parameters[:ip],
                                      parameters[:port],
                                      parameters[:timeout])
      elsif parameters[:type] == :TCP_CLIENT
        raise "not found :type" unless parameters.has_key? :type
        raise "not found :ip" unless parameters.has_key? :ip
        raise "not found :port" unless parameters.has_key? :port
        stream = StreamTCPClient.new( parameters[:name],
                                      parameters[:ip],
                                      parameters[:port],
                                      parameters[:timeout])
      elsif parameters[:type] == :WEB_SOCKET_SERVER
        raise "not found :type" unless parameters.has_key? :type
        raise "not found :ip" unless parameters.has_key? :ip
        raise "not found :port" unless parameters.has_key? :port
        stream = StreamWebSocketServer.new( parameters[:name],
                                            parameters[:ip],
                                            parameters[:port],
                                            parameters[:timeout])
      elsif parameters[:type] == :SERIAL
        raise "not found :port" unless parameters.has_key? :port
        raise "not found :baud_rate" unless parameters.has_key? :baud_rate
        raise "not found :data_bits" unless parameters.has_key? :data_bits
        raise "not found :stop_bits" unless parameters.has_key? :stop_bits
        raise "not found :parity" unless parameters.has_key? :parity
        stream = StreamSerial.new( parameters[:name],
                                   parameters[:port],
                                   parameters[:baud_rate],
                                   parameters[:data_bits],
                                   parameters[:stop_bits],
                                   parameters[:parity])
      else
        raise "illegal parameter #{parameters[:type]}"
      end
    rescue => e
      # 異常フォーマット
      raise "#{self}.#{__method__}: " + e.message
      stream = nil
    end
    return stream
  end
  

end

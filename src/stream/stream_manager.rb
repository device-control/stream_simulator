# coding: utf-8

require "stream/stream_tcp_server"
require "stream/stream_tcp_client"

class StreamManager
  def self.create(parameters)
    stream = nil
    begin
      raise "parameters is nil" if parameters.nil?
      raise "not found :name" unless parameters.has_key? :name
      raise "not found :type" unless parameters.has_key? :type
      raise "not found :ip" unless parameters.has_key? :ip
      raise "not found :port" unless parameters.has_key? :port
      
      if parameters[:type] == :TCP_SERVER
        stream = StreamTCPServer.new( parameters[:name],
                                      parameters[:ip],
                                      parameters[:port],
                                      parameters[:timeout])
      elsif parameters[:type] == :TCP_CLIENT
        stream = StreamTCPClient.new( parameters[:name],
                                      parameters[:ip],
                                      parameters[:port],
                                      parameters[:timeout])
      else
        raise ":UDP format? not support."
      end
    rescue => e
      # 異常フォーマット
      raise "StreamManager::create error: " + e.message
      stream = nil
    end
    return stream
  end
  

end

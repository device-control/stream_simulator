# coding: utf-8

require "stream/stream_tcp_server"
require "stream/stream_tcp_client"

class StreamManager
  def self.create(parameters)
    stream = nil
    begin
      # TODO: parameters フォーマットチェックが必要
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

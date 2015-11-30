# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "stream_tcp_server"
require "stream_tcp_client"

class StreamManager
  def self.create(parameters)
    stream = nil
    begin
      # TODO: parameters フォーマットチェックが必要
      if parameters[:type] == "tcp_server"
        stream = StreamTCPServer.new( parameters[:name],
                                      parameters[:ip],
                                      parameters[:port],
                                      parameters[:timeout])
      elsif parameters[:type] == "tcp_client"
        stream = StreamTCPClient.new( parameters[:name],
                                      parameters[:ip],
                                      parameters[:port],
                                      parameters[:timeout])
      else
        raise "udp format. not support."
      end
    rescue
      # 異常フォーマット
      raise "StreamManager::create error: " + e.message
      stream = nil
    end
    return stream
  end
  

end

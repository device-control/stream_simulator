# coding: utf-8
require 'yaml'

class StreamSetting
  def self.load(file_path)
    map = Hash.new
    begin
      yml = YAML.load_file(file_path)
      # TODO: formatチェックする必要がある
      contents = yml["contents"]
      parameters = contents["parameters"]
      map[:type] = parameters["type"]
      map[:name] = parameters["name"]
      map[:timeout] = parameters["timeout"]
      if map[:type] =~ /^(tcp_server|tcp_client)$/
        map[:ip] = parameters["ip"]
        map[:port] = parameters["port"]
      elsif map[:type] =~ /^(udp)$/
        raise "udp format. not support."
      else
        # 異常フォーマット
        raise "illegal format"
      end
    rescue => e
      # 異常フォーマット
      raise "StreamSetting::load: error: " + e.message
      map = nil
    end
    return map
  end
end

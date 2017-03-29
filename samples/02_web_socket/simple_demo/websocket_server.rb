# coding: utf-8
require 'em-websocket'
require 'pp'
require 'pry'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

connnections = []

EM::WebSocket.start({:host => "127.0.0.1", :port => 8888}) do |ws_conn|
  ws_conn.onopen do
    connnections << ws_conn
    p "[EVENT] connection:"
    pp ws_conn
  end

  ws_conn.onmessage do |message|
    p "[EVENT] message:"
    p message
    connnections.each{|conn| conn.send(message) }
  end
  
  ws_conn.onbinary do |binary|
    p "[EVENT] binary:"
    p binary
    connnections.each{|conn| conn.send_binary(binary) }
  end
  
  ws_conn.onclose do
    p "[EVENT] close:"
    pp ws_conn
    connnections.delete(ws_conn)
  end
end


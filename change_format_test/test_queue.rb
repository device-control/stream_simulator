# coding: utf-8
require 'thread'


class MyEvent
  attr_accessor :name
end

q = Queue.new

th1 = Thread.start do
  while ev = q.pop
    if ev.name == :ev1
      puts "recv_ev1: #{ev.object_id} : #{ev.name}"
    elsif ev.name == :ev2
      puts "recv_ev2: #{ev.object_id} #{ev.name}"
    elsif ev.name == :ev3
      puts "recv_ev3: #{ev.object_id} #{ev.name}"
    else
      puts "ERROR: #{ev.object_id} #{ev.name}"
    end
  end
end

[:ev1, :ev2, :ev3, :ev_error].each{|event_name|
  sleep 1
  ev = MyEvent.new
  ev.name = event_name
  puts "send: #{ev.name}"
  q.push(ev)
}
ev2 = MyEvent.new
ev2.name = "test"
q.push(ev2)

q.push(nil) # 終了
th1.join

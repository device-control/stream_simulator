# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オートパイロット
class AutopilotRunner
  def initialize(stream, queue)
    @stream = stream
    @queue = queue
  end
  
  private
  def run
    while event = @queue.pop
      if event[:name] == :message_receive
        
        
      else
        puts "ERROR: unknown event name [#{event[:name]}]"
      end
    end

  end

  def start
    @thread = Thread.new(&method(:run))
  end
  
  def stop
    @thread.kill
    @thread.join
    @thread = nil
  end
  
end


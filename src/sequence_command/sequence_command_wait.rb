# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 待ち
class SequenceCommandWait
  def initialize(arguments)
    raise "not found :time" unless arguments.has_key? :time

    @arguments = arguments
  end
  
  def run
    StreamLog.instance.puts "command wait: time=\"#{@arguments[:time]}\""
    # TODO: 脱出方法を検討する必要があるはず
    if @arguments[:time] == :WAIT_FOR_EVER
      loop do
        sleep 1
      end
    end
    sleep @arguments[:time]
  end
end


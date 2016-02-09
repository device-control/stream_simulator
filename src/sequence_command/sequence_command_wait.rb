# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 待ち
class SequenceCommandWait
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    SequenceCommandWait.arguments_permit? parameters[:arguments]
    @arguments = parameters[:arguments]
  end

  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found :time" unless arguments.has_key? :time
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


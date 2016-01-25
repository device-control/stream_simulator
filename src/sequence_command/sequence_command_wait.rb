# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require '../log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 待ち
class SequenceCommandWait
  def initialize(arguments)
    @arguments = arguments
  end
  
  def run
    # TODO: 脱出方法を検討する必要があるはず
    if @arguments[:time] == :wait_for_ever
      loop do
        sleep 1
      end
    end
    sleep @arguments[:time]
  end
end


# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 待ち
class SequenceCommandSetVariable
  def initialize(arguments, messages)
    raise "not found :exec" unless arguments.has_key? :exec
    
    @arguments = arguments
    @variables = messages[:variables]
  end
  
  def run
    # 変数設定
    # - name: :SET_VARIABLE
    #   arguments:
    #     exec:
    #       - ":TEST1 = 0" 
    #       - ":TEST2 = 0" 
    # - name: :SET_VARIABLE
    #   arguments:
    #     exec: ":TEST += 1"
    execute_list = @arguments[:exec]
    execute_list = Array.new [execute_list] unless execute_list.instance_of? Array
    
    execute_list.each do |exec|
      begin
        StreamLog.instance.puts "exec: #{exec}"
        exec = exec.gsub(/\:[0-9a-zA-Z_]+/){|h|"@variables[#{h}]"}
        eval exec
      rescue => e
        raise "unknown exec [#{exec}]\"#{e.message}\""
      end
    end
  end
end


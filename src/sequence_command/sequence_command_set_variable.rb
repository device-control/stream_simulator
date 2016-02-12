# coding: utf-8

require 'log'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 待ち
class SequenceCommandSetVariable
  def initialize(parameters)
    raise "#{self.class}\##{__method__} parameters is nil" if parameters.nil?
    raise "#{self.class}\##{__method__} parameters[:messages] is nil" if parameters[:messages].nil?
    raise "#{self.class}\##{__method__} parameters[:variables] is nil" if parameters[:variables].nil?
    SequenceCommandSetVariable.arguments_permit? parameters[:arguments]
    
    @arguments = parameters[:arguments]
    @variables = parameters[:variables]
  end
  
  def self.arguments_permit?(arguments)
    raise "#{self}.#{__method__} arguments is nil" if arguments.nil?
    raise "#{self}.#{__method__} not found :exec" unless arguments.has_key? :exec
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
        # シンボルが@variablesになければ、初期化する(初期値=0)
        exec.scan(/\:([0-9a-zA-Z_]+)/) do |w|
          symbol = $1.to_sym
          @variables[symbol] = 0 unless @variables.has_key? symbol
        end
        
        StreamLog.instance.puts "command set variable: exec=\"#{exec}\""
        exec = exec.gsub(/\:[0-9a-zA-Z_]+/){|h|"@variables[#{h}]"}
        eval exec
      rescue => e
        raise "unknown exec [#{exec}]\"#{e.message}\""
      end
    end
  end
end


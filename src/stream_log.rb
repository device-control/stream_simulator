# coding: utf-8

require 'singleton'

class StreamLog
  include Singleton
  
  def initialize
    @nested_names = Array.new
    @logs = Array.new
  end

  # 動作名登録
  # type = :scenario, :sequence, :command
  # name = 各name
  def push(type,name)
    space = '  ' * @nested_names.size
    @logs << "->#{space}#{type}[#{name}]"
    hash = Hash.new
    hash[:type] = type
    hash[:name] = name
    @nested_names << hash
  end
  
  # 動作名削除
  def pop
    hash = @nested_names.pop
    space = '  ' * @nested_names.size
    @logs << "<-#{space}#{hash[:type]}[#{hash[:name]}]"
  end

  def puts(format)
    space = '  ' * @nested_names.size
    @logs << "  #{space}#{format}"
  end
  
  def puts_message(msg)
    puts "message_member_list:"
    msg.each.with_index(0) do |member|
      value = member[:data].to_form member[:value]
      puts "  - #{member[:name]}: #{value}"
    end
  end
  
  # ファイル書き出し for Windows
  def write_dos(file_path)
    write(file_path)
  end

  # ファイル書き出し
  def write(file_path,to='cp932',from='utf-8')
    File.open(file_path,"w:#{to}:#{from}") do |file|
      file.write @logs.join("\n");
    end
  end
end


# StreamLog.instance.push :scenario, "scenario00"
# StreamLog.instance.push :sequence, "sequence00"
# StreamLog.instance.push :command, "command00"
# # ここにコマンド別のログを追加
# StreamLog.instance.pop
# StreamLog.instance.pop
# StreamLog.instance.pop
# StreamLog.instance.write "test.log"

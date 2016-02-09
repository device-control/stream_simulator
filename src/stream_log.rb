# coding: utf-8

require 'singleton'

class StreamLog
  include Singleton
  
  def initialize
    @mutex = Monitor.new
    reset
    # @nested_names = Array.new
    # @logs = Array.new
    # @error = nil # Hash.new # シナリオ終了時
    # @warnings = Array.new # 警告発生時
  end

  def reset
    @nested_names = Array.new
    @logs = Array.new
    @error = nil # Hash.new # シナリオ異常終了時のログ情報
    @warnings = Array.new # 警告発生時のログ情報
  end

  def get_position
    positions = Array.new
    @nested_names.each do |nested_name|
      positions << nested_name[:name]
    end
    return positions.join('.')
  end

  # 動作位置名を登録
  # type = :scenario, :sequence, :command
  # name = 各name
  def push(type,name)
    @mutex.synchronize {
      space = '  ' * @nested_names.size
      @logs << "->#{space}#{type}[#{name}]"
      hash = Hash.new
      hash[:type] = type
      hash[:name] = name
      @nested_names << hash
      @logs << "  #{space}position: " + get_position # 今の位置を出力
    }
  end
  
  # 動作位置名を削除
  def pop
    @mutex.synchronize {
      return if @nested_names.size == 0
      hash = @nested_names.pop
      space = '  ' * @nested_names.size
      @logs << "<-#{space}#{hash[:type]}[#{hash[:name]}]"
    }
  end

  # ログ出力
  def puts(message,details=Array.new)
    @mutex.synchronize {
      space = '  ' * @nested_names.size
      @logs << "  #{space}#{message}"
      details.each do |detail|
        space = '  ' * (@nested_names.size + 1)
        @logs << "  #{space}#{detail}"
      end
    }
  end

  # error 時
  def puts_error(message,details)
    @mutex.synchronize do
      @error = Hash.new
      @error[:message] = message
      @error[:details] = details
      @error[:position] = get_position
    end
  end
  
  # warning 時
  def puts_warning(message,details)
    @mutex.synchronize do
      warning = Hash.new
      warning[:message] = message
      warning[:details] = details
      warning[:position] = get_position
      @warnings << warning
    end
  end
  
  
  # ファイル書き出し for Windows
  def write_dos(file_path)
    write(file_path)
  end

  # ファイル書き出し
  def write(file_path,to='cp932',from='utf-8')
    @mutex.synchronize {
      File.open(file_path,"w:#{to}:#{from}") do |file|
        # 結果書き込み
        if @error.nil?
          file.write "[OK]\n"
        else
          file.write "[ERROR]\n"
          file.write " position: #{@error[:position]}\n"
          file.write " message: #{@error[:message]}\n"
          @error[:details].each do |detail|
            file.write "  #{detail}\n"
          end
        end
        # 警告書き込み
        if @warnings.size != 0
          file.write "[WARNING] #{@warnings.size}\n"
          @warnings.each.with_index(1) do |warning,index|
            file.write " #{index}:\n"
            file.write " position: #{warning[:position]}\n"
            file.write " message: #{warning[:message]}\n"
            warning[:details].each do |detail|
              file.write "  #{detail}\n"
            end
          end
        end
        
        # ログ書き込み
        file.write "[LOGS]\n"
        file.write @logs.join("\n");
      end
      # @nested_names.clear
      # @logs.clear
    }
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

# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "optparse"
require "yaml_reader"
require "message_utils"

require "pry"

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

class MakeJava
  extend MessageUtils
  # message_format だけを取得
  def self.get_formats(path)
    formats = Array.new
    begin
      ymls = YamlReader.get_yamls(path)
      ymls.each do |info|
        file = info[:file]
        yml = info[:yaml]
        
        next if yml["content-version"] != 0.1 # 0.1 以外は未対応
        next if yml["content-type"] != "message_format" # message_format以外は対象外
        
        contents = yml["contents"]
        raise "illigal message_format. #{file}" if contents == nil
        
        message_data = Hash.new
        formats << message_data
        
        message_data[:name] = contents["name"][9..(contents["name"].size-1)] + '_' + contents["name"][0,8] # クラス名
        message_data[:items] = contents["format"].clone
      end
    rescue => e
      # TODO:error取扱を考慮する必要がある。。。とりあえず全て例外ほっとく。
      raise e.message
    end
    return formats
  end
  
  def self.export(path, formats)
    javasrc = <<-EOS
/**
* @CLASS_NAME@クラス
*/
public class @CLASS_NAME@ extends MessageBase { // implements MessageBase {
	public @CLASS_NAME@() {
		super();
@INITIALIZE@
	}
}
EOS
    formats.each.with_index(0) do |format,index|
      class_name = format[:name].gsub(/\./,"_")
      # puts "\n#{index} : class name:" + class_name
      java_file = "#{path}/#{class_name}.java"
      puts java_file
      list = Array.new
      format[:items].each do |item|
        # puts "#{item["name_jp"]} #{item["name"]} #{item["type"]} #{item["default_value"]}"
        #puts item
        byte_size = type_size(item["type"]) * type_array_count(item["type"])
        bin_string = convert_message(item["default_value"], item["type"])
        list << "\t\t// #{item["name_jp"]}"
        list << "\t\tkey_list.add(\"#{item["name"]}\");"
        list << "\t\tsize_list.add(new Integer(#{byte_size});"
        list << "\t\tmap.put(\"#{item["name"]}\", \"#{bin_string}\");"
      end
      src = javasrc.clone
      src.gsub!(/@CLASS_NAME@/){|item| class_name}
      src.gsub!(/@INITIALIZE@/){|item| list.join("\n") }
      #puts src
      File.write(java_file, src)
    end
  end
end

# main

# オプション
options = Hash.new
opt = OptionParser.new
opt.on('-b VAL', '--byte VAL') {|val| options[:b] = val } # dummy 未使用
opt.on('-d', '--debug') {|val| options[:debug] = val } # dummy 未使用

argv = opt.parse(ARGV)
if argv.length != 2 then
  abort "usage: mkjava [yaml path] [output path]"
end

formats = MakeJava.get_formats(argv[0].encode('utf-8'))
MakeJava.export(argv[1].encode('utf-8'), formats)

puts 'complete.'


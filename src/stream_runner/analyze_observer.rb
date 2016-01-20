# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

module AnalyzeObserver
  
  def initialize
    @observers = Array.new
  end
  
  def add_observer(observer)
    @observers << observer
  end
  
  def delete_observer(observer)
    @observers.delete(observer)
  end
  
  def notify_analyze_result(result)
    @observers.each do |observer|
      observer.analyze_result_received(self, result)
    end
  end
  
end

# coding: utf-8

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# オブザーバパターン 参考
# http://qiita.com/kidach1/items/ce18d2a926c558159689
# http://morizyun.github.io/blog/ruby-design-pattern-03-Observer/
module StreamObserver
  STATUS = 0 # 接続状態通知
  MESSAGE =1 # 受信メッセージ通知

  def initialize
    @observers = Array.new(3){ Array.new }
  end

  def add_observer(type, observer)
    @observers[type] << observer
  end

  def delete_observer(type, observer)
    @observers[type].delete(observer)
  end

  # 切断を通知
  # オブザーバは stream_disconnected を実装する必要がある
  # type には SERVER or CLIENT が設定される
  def notify_disconnect
    @observers[STATUS].each do |observer|
      observer.stream_disconnected(self)
    end
  end

  # 接続を通知
  # オブザーバは stream_connected を実装する必要がある
  def notify_connect
    @observers[STATUS].each do |observer|
      observer.stream_connected(self)
    end
  end
  
  # 受信したメッセージを通知
  # オブザーバは message_received を実装する必要がある
  def notify_message(message)
    @observers[MESSAGE].each do |observer|
      observer.stream_message_received(self,message)
    end
  end

end


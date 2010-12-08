require 'xmpp4r'

module Jabber
  class Client
    def say (text,to)
      msg = Message.new
      msg.type = :chat
      msg.to = to
      msg.body = text
      send(msg)
    end
  end
end

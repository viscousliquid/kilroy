require 'xmpp4r/callbacks'
require 'kilroy/dsl'


module Jabber
  module Bot
    class Engine
      include Jabber::Bot::DSL

      attr_accessor :snarfers

      def initialize(stream)
        @snarfers = Jabber::CallbackList.new
      end

      def load(name, body)
        unless body.nil?
          self.instance_eval(body, name)
        end
      end

      def load_file(path)
        unless path.nil?
          self.instance_eval(File.read(path),path)
        end
      end

      def help(client,from,cmd)
        if respond_to? "help_#{cmd}".to_sym
          self.call("help_#{cmd}".to_sym, client, from)
        else
          client.say "No help defined for #{cmd}", from
        end
      end
    end
  end
end

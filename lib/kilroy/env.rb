require 'rubygems'
require 'kilroy/models'

module Jabber
  module Bot
    class Environment
      include Jabber::Bot::Models

      STD_KEYS = %w[ jid passwd host cert ]

      attr_accessor :module_path

      def initialize()

        @module_path = File.expand_path(File.dirname(__FILE__))
      end

      def [](key)
        Configuration.value key
      end

      def []=(key,value)
        Configuration.store key, value
      end

      def to_hash
        values = {}
        Configuration.all.each { |r| values[r.key] = r.value }
        
        values
      end

      def to_json
        values = {}
        Configuration.all.each { |r| values[r.key] = r.value }
        
        values.to_json
      end
    end
  end
end

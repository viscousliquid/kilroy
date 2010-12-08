require "kilroy/models"

module Jabber
  module Bot
    class Recorder
      IM_MSG  = 1
      MUC_MSG = 2

      def initialize
      end

      def error(e)
        puts "#{e}\n#{e.message}\n#{e.backtrace}"
        if e.is_a? Exception
          Jabber::Bot::Models::Log.create(
            :etype => e,
            :message => e.message,
            :trace => e.backtrace)
        end
      end

      def im(from,text)
        Jabber::Bot::Models::Message.create(
          :mtype => IM_MSG,
          :jid => from.to_s,
          :message => text)
      end

      def muc(room,time,nick,text,priv=false)
        Jabber::Bot::Models::Message.create(
          :mtype => MUC_MSG,
          :time => time,
          :room => room,
          :jid => nick,
          :private => priv,
          :message => text)
      end

      # return the last 20 messages unless given a start point
      def get_im (start=nil, count=20, query='%')
        if start.nil?
          total = Jabber::Bot::Models::Message.count(:conditions => { :mtype => IM_MSG })
          start = (total - count) > 0 ? total - count : 0
        end

        Jabber::Bot::Models::Message.all(:limit => count, :offset => start, :conditions => [ "mtype = ? AND message LIKE ?", IM_MSG, query ])
      end

      def get_rooms()
        Jabber::Bot::Models::Message.all(:select => "DISTINCT(room)", :conditions => { :mtype => MUC_MSG })
      end

      # return the last 20 messages unless given a start point
      def get_muc (room, start=nil, count=20, query='%')
        if start.nil?
          total = Jabber::Bot::Models::Message.count(:conditions => { :mtype => MUC_MSG })
          start = (total - count) > 0 ? total - count : 0
        end

        Jabber::Bot::Models::Message.all(:limit => count, :offset => start, :conditions => [ "mtype = ? AND message LIKE ?", MUC_MSG, query ])
      end

    end
  end
end

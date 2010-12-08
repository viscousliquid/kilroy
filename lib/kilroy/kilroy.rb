require 'xmpp4r'
require 'xmpp4r/muc'
require 'xmpp4r/discovery'
require 'xmpp4r/framework/bot'

module Jabber
  module Bot
    class Kilroy < Jabber::Framework::Base
      attr_reader :env, :recorder

      def initialize()
          super(Jabber::Client.new "")

          @env = Jabber::Bot::Environment.new
          @recorder = Jabber::Bot::Recorder.new
          @mucs = []
      end

      def connect()
        begin
          cl = Jabber::Client.new(env['jid'])
          cl.connect(env['host'])
          cl.auth(env['password'])

          @stream = cl

          # Clear out any previous helpers from a previous connection
          @helpers_lock.synchronize do
            @helpers = {}
          end

          class << self
            helper(:engine, Jabber::Bot::Engine)
            helper(:roster, Roster::Helper)
            helper(:disco) { |c|
              Discovery::Responder.new(c,
                "http://home.gna.org/xmpp4r/#{Jabber::XMPP4R_VERSION}",
                [Jabber::Discovery::Identity.new('client', 'Kilroy Was Here', 'bot')]
              )
            }
          end

          roster.add_subscription_request_callback do |item,presence|
            roster.add(presence.from.strip, nil, true)
            roster.accept_subscription(presence.from.strip)
          end

          set_callbacks

          disco.add_feature('presence')
          disco.add_feature(Caps::NS_CAPS)
          disco.add_feature('message') if respond_to? :on_message
          
          load_modules

          set_presence(nil,'Chillin')
        rescue Exception => e
          puts "#{e}\n#{e.message}\n#{e.backtrace}"
          Process::exit
        end
      end

      def disconnect()
        @stream.close
      end

      def is_connected?
        @stream.is_connected?
      end

      def conference()
        nick = env['nick'].nil? ? @stream.jid.node : env['nick']
        rooms = env['rooms']
        rooms.each do |r|
          @mucs << Jabber::MUC::SimpleMUCClient.new(@stream)
          @mucs.last.join "#{r}/#{nick}"
          muc_callbacks(@mucs.last)
        end unless rooms.nil? or rooms.empty?
      end

      def leave(rooms=[], reason=nil)
        rooms = [ rooms ] unless rooms.is_a? Array
        if rooms.empty?
          @mucs.each do |m|
            m.exit(reason)
          end
        else
          @mucs.each do |m|
            m.exit(reason) if rooms.include? m.room
          end
        end
      end

      def rooms
        @mucs.collect do |m|
          m.room
        end
      end

      private

      def load_modules
        @helpers_lock.synchronize do
          @helpers[:engine] = Jabber::Bot::Engine.new(@stream)
        end

        Jabber::Bot::Models::Module.active.each { |m|
          mod = Jabber::Bot::Models::Module.get(m)
          engine.load(mod.name, mod.body)
        }
      end

      def set_callbacks
        # Log all incoming messages before we process them
        @stream.add_message_callback(99,:logging) do |msg|
          if msg.body
            recorder.im(msg.from, msg.body)
          end

          false
        end

        # Process incoming messages
        @stream.add_message_callback do |msg|
          begin
            if msg.type != :error and msg.body
              command, args = msg.body.split("\s",2)

              unless command == "help"
                command = "chat_" + command
                if engine.respond_to? command.to_sym
                  engine.send(command.to_sym, @stream, msg.from, args)
                else
                  @stream.say "What you want fool", msg.from
                end
              else
                engine.help(@stream,msg.from,args)
              end
            else
              false
            end
          rescue Exception => e
            recorder.error(e)
          end
        end
      end

      def muc_callbacks(muc)
        # MUC private message
        muc.on_private_message do |time,nick,text|
          begin
            recorder.muc(muc.room,time,nick,text,true)

            command, args = text.split("\s",2)
            unless command == "help"
              command = "groupchat_" + command

              if engine.respond_to? command.to_sym
                engine.send(command.to_sym, muc, args)
              else
                muc.say "What you want fool", nick
              end
            else
              engine.help(muc,nick,args)
            end
              
          rescue Exception => e
            recorder.error(e)
          end
        end

        # MUC group chat message
        muc.on_message do |time,nick,text|
          #Avoid reacting to room history
          unless time
            begin
              text.strip!
              recorder.muc(muc.room,time,nick,text)

              if text =~ /^#{env['delim']}/
                command, args = text.sub(/^#{env['delim']}/,'').split("\s",2)

                puts "==> found command #{command}"

                command = "groupchat_" + command
                if engine.respond_to? command.to_sym
                  engine.send(command.to_sym, muc, args)
                else
                  muc.say "What you want fool", nick
                end
              else
                engine.snafers.process(muc,nick,text)
              end
            rescue Exception => e
              recorder.error(e)
            end
          end
        end
      end

      def send_presence
        roster.wait_for_roster

        if @presence[:show] == :unavailable
          presence = Presence.new(nil, @presence[:status])
          presence.type = :unavailable
        else
          presence = Presence.new(@presence[:show], @presence[:status])
        end
        presence.add(disco.generate_caps)
        @stream.send(presence)
      end

      public

      def set_presence(show=nil,status=nil)
        @presence = { :show => show, :status => status }
        send_presence
      end

    end
  end
end

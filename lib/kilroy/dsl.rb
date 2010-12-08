
module Jabber
  module Bot
    module DSL
      extend self

      def metaclass; class << self; self; end; end

      def command(name, type, &block)
				if [ :chat, :groupchat ].include? type
					cmd = type.to_s + "_" + name.to_s
					unless metaclass.method_defined? cmd.to_sym
						metaclass.send(:define_method, cmd.to_sym, block)
					end
				end

        self
      end

# rewrite this to provide namespace for the methods,
# e.g. echo.fancy()
      def helper(&block)
        metaclass.class_eval(&block)

        self
      end

      def snarfer(name, &block)
        if block_given?
          unless @snarfers.is_a? Jabber::CallbackList
            @snarfers = Jabber::CallbackList.new
          end

          @snarfers.add(0,name,nil,block)
        end

        self
      end

      def help(name, &block)
        unless metaclass.method_defined? "help_#{name}".to_sym
          metaclass.send(:define_method, name.to_sym, block)
        end

        self
      end
    end
  end
end

require "rubygems"
require "activerecord"

module Jabber
  module Bot
    module Models
      class Configuration < ActiveRecord::Base
        serialize :value

        class << self
          def value(key)
            result = self.first(:conditions => {:key => key})
            result.nil? ? nil : result.value
          end

          def store(key,value)
            current = self.first(:conditions => {:key => key})
            record = current.nil? ? self.new(:key => key) : current
            unless record.value == value
              record.value = value
              record.save!
            end
            record
          end
        end
      end
    end
  end
end

require "rubygems"
require "activerecord"

module Jabber
  module Bot
    module Models
      class Module < ActiveRecord::Base
        OFFLINE = 0
        ACTIVE  = 1
        DELETED = 2

        class << self
          def get(name)
            self.find_last_by_name name
          end

          # This will return all modules revisioned including ones deleted in case there is a need to 
          # go into the archive of all modules ever ran by the bot.
          def list
            self.find(:all, :select => "DISTINCT(name)").map { |r| r.name }
          end

          def active
            self.find(:all, :select => "DISTINCT(name)", :conditions => {:state => ACTIVE}).map { |r| r.name }
          end

          def revisions(name)
            self.find_all_by_name name
          end
        end

        def revision(params)
        # creates a new revision of this object with the params hash used for the modifications
          record = self.class.new
          %w[mod_id name description state body rev_user_id].each { |k|
            record[k] = params.has_key?(k) ? params[k] : self[k]
          }
          record.save!

          record
        end

        def rollback(user_id,version)
          params = {'rev_user_id' => user_id}
          record = self.class.find(version)
          %w[mod_id name description state body].each { |k|
            params[k] = record[k]
          }

          revision(params)
        end

        def delete(user_id)
          revision( 'state' => DELETED, 'rev_user_id' => user_id )
        end

        # TODO: whether should add both a class and instance method to diff two revisions
      end
    end
  end
end

#  /* id is the global unique revision control number. 
#      This is because AR is dependant on id being unique */
#  `id`            int(11)       NOT NULL AUTO_INCREMENT,
#  `mod_id`        int(11)       NOT NULL,
#  `name`          varchar(56)   DEFAULT NULL,
#  `description`   varchar(255)  DEFAULT NULL,
#  `state`         int           DEFAULT NULL,
#  `body`          text,
#  `rev_user_id`   int(11)       NOT NULL,
#  `rev_time`      timestamp     DEFAULT NOW(),



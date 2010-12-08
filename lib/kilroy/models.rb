require "active_record"

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
  :adapter => "mysql",
  :host => ENV["mysql_default_host"],
  :username => ENV["mysql_default_user"],
  :password => ENV["mysql_default_password"],
  :database => ENV["mysql_default_db"])

require "kilroy/models/configuration"
require "kilroy/models/messages"
require "kilroy/models/modules"
require "kilroy/models/logs"

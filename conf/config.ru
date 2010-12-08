root_dir = File.expand_path(File.dirname(__FILE__) + '/..')

$:.unshift(root_dir)
$:.unshift(root_dir + '/lib')

require 'rubygems'
require 'sinatra'
require 'app/service'

set :environment, :production
set :root,  root_dir + '/app'
disable :run

run Sinatra::Application

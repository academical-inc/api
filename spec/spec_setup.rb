ENV['RACK_ENV'] = 'test'

require File.expand_path '../api.rb', __FILE__

require 'rspec'
require 'rack/test'
require 'factory_girl'
require 'database_cleaner'
require 'byebug'

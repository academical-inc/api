ENV['RACK_ENV'] = 'test'

# Initialized early for coverage tracking.
require 'simplecov'
SimpleCov.start

require File.expand_path '../../api.rb', __FILE__

require 'rspec'
require 'rack/test'
require 'factory_girl'
require 'pry'
require 'byebug'
require 'database_cleaner'
require 'spec/support/helpers'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods
  config.include Helpers

  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :suite do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  def app
    Academical::Api
  end
end

FactoryGirl.find_definitions
Dir['spec/support/**/*.rb'].sort.each { |f| require f }

# Silence Searchkick Activejob notifications.
ActiveJob::Base.logger = Logger.new(nil)

# Bugsnag warnings.
Bugsnag.configure do |config|
  config.logger = Logger.new(nil)
end

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../api.rb', __FILE__

require 'rspec'
require 'rack/test'
require 'factory_girl'
require 'byebug'
require 'database_cleaner'

RSpec.configure do |config|

  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods

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

  def api
    Academical::Api
  end

  def base_model_name
    "Academical::Models::"
  end

end

FactoryGirl.find_definitions

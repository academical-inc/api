#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

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
    Academical::Api.cache.clear
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

require 'rubygems'
require 'bundler/setup'

# Set up load paths
Bundler.require(:default)
$: << File.expand_path('../', __FILE__)

Dotenv.load

# Require gems
require 'sinatra/reloader'
require 'sinatra/json'
require 'active_support/core_ext/string'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'active_support/json'
require 'i18n/backend/fallbacks'
require 'logger'

# Initializers
require 'config/initializers'

# Require from lib
require 'lib/exceptions'
require 'lib/utils'

# Bootstrap config
module Academical
  class Api < Sinatra::Application

    configure do
      set :root, Bundler.root.to_s

      disable :method_override
      disable :static
      disable :sessions
    end

    configure do
      Time.zone = "UTC"
    end

    configure do
      I18n.enforce_available_locales = true
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.load_path += Dir[File.join(root, 'config/locales', '*.yml')]
      I18n.available_locales = [:en, :es]
      I18n.backend.load_translations
      I18n.default_locale = :en
    end

    configure do
      Mongoid.load!('config/mongoid.yml')
    end

    Bugsnag.configure do |config|
      config.release_stage = ENV['BUGSNAG_RELEASE_STAGE']
      config.notify_release_stages = ["production", "staging"]
    end

    configure do
      newrelic_ignore "/status"
    end

    configure :development do
      register Sinatra::Reloader
    end

  end
end

# Require middleware config
require 'app/middleware'

# Require helpers, models and routes
require 'app/helpers'
require 'app/models'
require 'app/routes'


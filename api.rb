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
require 'active_support/cache/dalli_store'
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
      Mongo::Logger.logger.level = Logger::INFO
    end

    configure do
      servers = ENV['MEMCACHE_SERVERS'].split(',')
      set :cache, ActiveSupport::Cache::DalliStore.new(
        *servers,
        namespace: "academical-api-#{environment}",
        expires_in: ENV['MEMCACHE_EXPIRES'].to_i.minutes,
        pool_size: 50,
        pool_timeout: 5
      )
    end

    configure :production, :staging do
      Mongoid::CachedJson.configure do |config|
        config.cache = settings.cache
        config.disable_caching = ENV['DISABLE_JSON_CACHING'] == 'true'
      end
    end

    Bugsnag.configure do |config|
      config.release_stage = ENV['BUGSNAG_RELEASE_STAGE']
      config.notify_release_stages = ["production", "staging", "development"]
    end

    configure :production, :staging do
      Bugsnag.configure do |config|
        config.project_root = "/var/app/current"
      end
    end

    configure :production, :staging do
      newrelic_ignore "/status"
    end

    configure :development do
      register Sinatra::Reloader
    end

    def self.global_cache
      settings.cache
    end

  end
end

# Require middleware config
require 'app/middleware'

# Require helpers, models and routes
require 'app/helpers'
require 'app/models'
require 'app/routes'


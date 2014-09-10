require 'rubygems'
require 'bundler/setup'

# Set up load paths
Bundler.require(:default)
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

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

# Require from lib
require 'exceptions'
require 'utils'

# Bootstrap config
module Academical
  class Api < Sinatra::Application

    configure do
      disable :method_override
      disable :static
      disable :sessions

      set :root, Bundler.root.to_s
      set :views, 'app/views'

      set :httponly     => true,
          :secure       => production?,
          :expire_after => 31557600, # 1 year
          :secret       => ENV['SESSION_SECRET']
    end

    configure do
      I18n.enforce_available_locales = true
      I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      I18n.load_path = Dir[File.join(root, 'config/locales', '*.yml')]
      I18n.available_locales = [:en, :es]
      I18n.backend.load_translations
    end

    configure do
      Mongoid.load!('config/mongoid.yml')
    end

    configure :development do
      register Sinatra::Reloader
    end

    configure :production do
      set :haml, { :ugly=>true }
      set :clean_trace, true
    end

    helpers Sinatra::JSON

    use Rack::Deflater
  end
end

# Require helpers, models and routes
require 'app/helpers'
require 'app/models'
require 'app/routes'


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

# Require from lib
require 'utils'

# Bootstrap config
module Academical
  class Api < Sinatra::Application
    configure :development do
      register Sinatra::Reloader
    end

    configure :production do
      set :haml, { :ugly=>true }
      set :clean_trace, true
    end

    configure do
      I18n.enforce_available_locales = true
      Mongoid.load!('config/mongoid.yml')

      disable :method_override
      disable :static
      disable :sessions

      set :views, 'app/views'

      set :httponly     => true,
          :secure       => production?,
          :expire_after => 31557600, # 1 year
          :secret       => ENV['SESSION_SECRET']
    end

    helpers Sinatra::JSON

    use Rack::Deflater
  end
end

# Require helpers, models and routes
require 'app/exceptions'
require 'app/helpers'
require 'app/models'
require 'app/routes'


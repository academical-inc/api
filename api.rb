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

require 'app/helpers'

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
    helpers Helpers

    use Rack::Deflater
  end
end

# Require helpers, models and routes
require 'app/models'
require 'app/routes'


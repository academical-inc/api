require 'rubygems'
require 'bundler'

# Set up load paths
Bundler.require
$: << File.expand_path('../', __FILE__)

Dotenv.load

# Requires
require 'sinatra/base'
require 'sinatra/reloader'
require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'active_support/json'
require 'app/helpers'

module Academical
  class Api < Sinatra::Application
    configure :development do
      register Sinatra::Reloader
    end

    configure do
      disable :method_override
      disable :static
      disable :sessions

      set :httponly     => true,
          :secure       => production?,
          :expire_after => 31557600, # 1 year
          :secret       => ENV['SESSION_SECRET']
    end

    use Rack::Deflater
  end
end

# Routes
require 'app/routes/base'
require 'app/routes/schools'

module Academical
  class Api
    use Routes::Base
    use Routes::Schools
  end
end

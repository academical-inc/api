require 'rubygems'
require 'bundler'

# Set up load paths
Bundler.require
$: << File.expand_path('../', __FILE__)

Dotenv.load

# Requires
require 'app/helpers'

module Academical
  class Api < Sinatra::Application
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

module Academical
  class Api
    use Routes::Base
  end
end

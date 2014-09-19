module Academical
  module Routes
    class Base < Sinatra::Base

      configure do
        set :root, Api.root
        set :views, 'app/views'

        disable :raise_errors
        disable :dump_errors
        disable :show_exceptions
        disable :protection
      end

      configure :production do
        set :haml, { :ugly=>true }
        set :clean_trace, true
      end

      helpers Sinatra::JSON
      helpers Helpers::CommonHelpers

    end
  end
end

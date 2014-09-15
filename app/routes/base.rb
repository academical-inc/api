module Academical
  module Routes
    class Base < Sinatra::Application

      configure do
        set :root, Api.root
        set :views, 'app/views'

        disable :method_override
        disable :protection
        disable :static
      end

    end
  end
end

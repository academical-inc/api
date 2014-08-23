module Academical
  module Routes
    class Base < Sinatra::Application
      configure do
        set :views, 'app/views'
        set :root, Api.root

        disable :static
      end

      helpers Helpers

    end
  end
end

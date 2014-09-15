module Academical
  module Routes
    class Main < Base

      get '/' do
        haml :index
      end

    end
  end
end

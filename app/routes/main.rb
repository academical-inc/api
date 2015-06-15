module Academical
  module Routes
    class Main < Base

      get '/' do
        authorize! do
          is_admin?
        end

        haml :index
      end

    end
  end
end

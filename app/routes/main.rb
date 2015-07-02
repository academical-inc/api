module Academical
  module Routes
    class Main < Base

      get '/' do
        authorize! do
          is_admin?
        end

        haml :index
      end

      get "/status" do
        status = "Ok!"
        json_response status
      end
    end
  end
end

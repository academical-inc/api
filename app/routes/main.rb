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
        halt 200, {status: status}.to_json
      end
    end
  end
end

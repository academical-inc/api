module Academical
  module Routes
    class Schools < Base

      get '/schools/:id' do
        {'school' => params[:id]}.to_json
      end

    end
  end
end

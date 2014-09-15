module Academical
  module Routes
    class Schools < Base

    get '/schools/:id' do
      json 'school' => params[:id]
    end

    post '/schools' do
      puts params[:json]
      json create_school(params[:json])
    end





    end
  end
end

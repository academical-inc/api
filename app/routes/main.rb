module Academical
  class Api < Sinatra::Application

    get '/' do
      haml :index
    end

  end
end

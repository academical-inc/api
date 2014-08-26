module Academical
  class Api < Sinatra::Application

    before do
      halt 406 unless request.accept? 'application/json'
      next if request.get?
      begin
        params[:json] = JSON.parse(request.body.read)
      rescue JSON::ParserError
      end
    end

  end
end

module Academical
  class Api < Sinatra::Application

    # Set up all middleware and config here
    use Rack::BounceFavicon
    use Rack::Deflater
    use Rack::Parser,
    parsers: {
      'application/json' => lambda { |body| MultiJson.load body }
    },
    handlers: {
      'application/json' => lambda do |ex, type|
        error_hash = ResponseUtils.error_hash Api.production?,
          Api.development?, message: "Problems parsing JSON"
        [ 400, { 'Content-Type' => type }, [error_hash.to_json] ]
      end
    }

  end
end

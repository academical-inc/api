module Academical
  module Helpers
    module CommonHelpers

      def extract!()
        # TODO
      end

      def json_error(code, ex: env['sinatra.error'], message: nil, errors: {})
        response_hash = ResponseUtils.error_hash settings.production?,
          settings.development?, ex: ex, message: message, errors: errors
        halt code, json(response_hash)
      end

      def json_response(data, code: 200)
        response_hash = ResponseUtils.success_hash data
        status code
        json response_hash
      end

    end
  end
end

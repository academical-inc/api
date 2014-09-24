module Academical
  module Helpers
    module CommonHelpers

      module_function

      def result(res, count)
        if count == true
          res.count
        else
          res
        end
      end

      def contains?(key, hash=params)
        hash.symbolize_keys!
        hash.key? key.to_sym
      end

      def extract!(key, hash=params)
        hash.symbolize_keys!
        key = key.to_sym
        raise ParameterMissingError, key if not hash.key? key
        hash[key]
      end

      def json_error(code, ex: env['sinatra.error'], message: nil, errors: {})
        response_hash = error_hash settings.production?, settings.development?,
          ex: ex, message: message, errors: errors
        halt code, json(response_hash)
      end

      def json_response(data, code: 200)
        response_hash = success_hash data
        status code
        json response_hash
      end

    end
  end
end

module Academical
  module Helpers
    module CommonHelpers

      module_function

      def get_result(res, count)
        if count == true
          if res.respond_to? :count then res.count else 1 end
        else
          res
        end
      end

      def remove_key(key, hash=params)
        hash.symbolize_keys!
        hash.except key.to_sym
      end

      def contains?(key, hash=params)
        hash.symbolize_keys!
        hash.key? key.to_sym
      end

      def extract(key, hash=params)
        hash.symbolize_keys!
        key = key.to_sym
        hash[key]
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
        halt code, json(response_hash)
      end

    end
  end
end

module Academical
  module Helpers
    module CommonHelpers

      module_function

      def get_result(res, count)
        if count == true
          if res.nil?
            0
          else
            if res.respond_to? :count then res.count else 1 end
          end
        else
          res
        end
      end

      def remove_key(key, hash=params)
        hash.symbolize_keys!
        hash.except key.to_sym
      end

      def contains?(key, hash=params)
        h = hash.symbolize_keys
        h.key? key.to_sym
      end

      def extract(key, hash=params)
        h = hash.symbolize_keys
        key = key.to_sym
        h[key]
      end

      def extract!(key, hash=(hash_set=true; params))
        h = hash.symbolize_keys
        key = key.to_sym
        raise ParameterMissingError, key if not h.key? key and hash_set
        h.fetch(key)
      end

      def extract_nested!(key, hash=(hash_set=true; params))
        val = hash
        key.to_s.split(".").each do |k|
          begin
            val = extract! k, val
          rescue => ex
            raise ParameterMissingError, key if hash_set
            raise ex if not hash_set
          end
        end
        val
      end

      def extract_all!(keys, hash)
        values = {}
        keys.each do |key|
          if key.to_s.include? "."
            values[key] = extract_nested!(key, hash)
          else
            values[key] = extract!(key, hash)
          end
        end
        values.stringify_keys
      end

      def clean_hash_default_proc!(hash=params)
        case hash
        when Hash
          hash.default_proc = nil
          hash.each { |key, val| clean_hash_default_proc!(val) }
        when Array
          hash.each { |val| clean_hash_default_proc!(val) }
        end
      end

      def json(hash, camelize: contains?(:camelize))
        hash = camelize_hash_keys hash if camelize
        content_type settings.api_content_type, charset: settings.api_charset
        MultiJson.dump hash
      end

      def json_error(code, ex: env['sinatra.error'], message: nil, errors: {},
                    data: nil)
        response_hash = error_hash settings.production?, settings.development?,
          ex: ex, message: message, errors: errors, data: data
        halt code, json(response_hash)
      end

      def json_response(data, options: {}, code: 200)
        if not options.key? :version
          options[:version] = "v#{current_school.nickname}".to_sym
        end
        response_hash = success_hash data, options
        halt code, json(response_hash)
      end

      def titleize(str)
        str.mb_chars.titleize.to_s
      end

      def camelize_hash_keys(hash)
        res = {}
        hash.each_pair do |key, val|
          case val
          when Hash
            val = camelize_hash_keys(val)
          when Array
            val = val.map { |v|
              if v.is_a? Hash then camelize_hash_keys(v) else v end
            }
          end
          res[key.to_s.camelize(:lower)] = val
        end
        res
      end

    end
  end
end

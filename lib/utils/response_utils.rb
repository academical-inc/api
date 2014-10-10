module Academical
  module Utils
    module ResponseUtils

      module_function

      def error_hash(prod, dev, ex: nil, message:nil, errors: [])
        message = if not message.blank?
          message
        elsif not ex.blank? and not prod
          ex.message
        else
          "Something went wrong. Please try again later"
        end

        response_hash = {
          success: false,
          message: message,
          errors: errors
        }
        response_hash[:backtrace] = ex.backtrace if dev and not ex.blank?

        response_hash
      end

      def success_hash(data)
        response_hash = if data.respond_to?(:key?)
          if data.key?(:data) or data.key?("data")
            data.symbolize_keys
          else
            {data: data}
          end
        elsif data.respond_to? :each
          {data: data.as_json(root: :data)}
        else
          data.as_json root: :data
        end

        hash_is_valid = begin
          response_hash.fetch(:data)
        rescue
          false
        end

        response_hash = {data: response_hash} unless hash_is_valid
        response_hash.merge({success: true})
      end

    end
  end
end

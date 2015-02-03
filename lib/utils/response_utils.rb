module Academical
  module Utils
    module ResponseUtils

      module_function

      def error_hash(prod, dev, ex: nil, message:nil, errors: [], data: nil)
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
        response_hash[:data] = data if not data.blank?
        response_hash[:backtrace] = ex.backtrace if dev and not ex.blank?

        response_hash
      end

      def success_hash(data)
        is_hash = data.is_a? Hash
        contains_data_key = (is_hash and (data.key? :data or data.key? "data"))

        response_hash = if contains_data_key
          data.symbolize_keys
        else
          {data: data.as_json}
        end

        # response_hash = {data: response_hash} unless hash_is_valid
        response_hash.merge({success: true})
      end

    end
  end
end

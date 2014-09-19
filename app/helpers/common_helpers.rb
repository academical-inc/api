module Academical
  module Helpers
    module CommonHelpers

      def extract!()
        # TODO
      end

      def json_error(code, ex: env['sinatra.error'], message: nil, errors: {})
          settings.set :environment, :production
        message = if not message.blank?
          message
        elsif not ex.blank? and not settings.production?
          ex.message
        else
          "Something went wrong. Please try again later"
        end

        response_hash = {
          success: false,
          message: message,
          errors: errors
        }

        response_hash[:backtrace] = ex.backtrace if settings.development?\
          and not ex.blank?

        halt code, json(response_hash)
      end

      def json_response(data, code: 200)
        response_hash = if data.respond_to? :each
          {
            data: data.as_json
          }
        else
          data.as_json
        end.merge({success: true})

        status code
        json response_hash
      end

    end
  end
end

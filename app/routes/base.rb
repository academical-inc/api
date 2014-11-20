module Academical
  module Routes
    class Base < Sinatra::Base

      configure do
        set :root, Api.root
        set :views, 'app/views'
        set :req_content_type, 'application/json'

        disable :dump_errors
        disable :show_exceptions
        disable :protection
      end

      configure :production do
        set :haml, { :ugly=>true }
        set :clean_trace, true
      end

      helpers ResponseUtils
      helpers CommonHelpers

      before do
        if request.post? or request.put?
          if request.content_type != settings.req_content_type
            json_error 400,
              message: "The request Content-Type must be application/json"
          end
        end
      end

      error do
        dump_errors! env['sinatra.error']
        json_error 500
      end

      not_found do
        json_error 404, message: "The requested path is unknown"
      end

      error ParameterMissingError do
        json_error 400, message: env['sinatra.error'].message
      end

      error InvalidParameterError do
        json_error 400, message: env['sinatra.error'].message
      end

      error Mongoid::Errors::DocumentNotFound do
        json_error 404, message: "The resource was not found"
      end

      error Mongoid::Errors::DocumentsNotFound do
        ex = env['sinatra.error']
        json_error 404, message: ex.message, data: ex.found
      end

      error Mongoid::Errors::DuplicateKey do
        json_error 422, message: env['sinatra.error'].message
      end

      error Mongoid::Errors::UnknownAttribute do
        field = env['sinatra.error'].attr_name
        json_error 422,
          message: "The resource contains an unknown field: #{field}"
      end

      error Mongoid::Errors::Validations do
        errors = env['sinatra.error'].document.errors.full_messages
        json_error 422,
          message: "The data for the resource is incomplete or invalid",
          errors: errors
      end

    end
  end
end

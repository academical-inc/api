module Academical
  module Routes
    class Base < Sinatra::Base

      configure do
        set :root, Api.root
        set :views, 'app/views'

        disable :dump_errors
        disable :show_exceptions
        disable :protection
      end

      configure :production do
        set :haml, { :ugly=>true }
        set :clean_trace, true
      end

      helpers Sinatra::JSON
      helpers ResponseUtils
      helpers CommonHelpers

      error do
        dump_errors! env['sinatra.error']
        json_error 500
      end

      not_found do
        json_error 404, message: "The requested path is unknown"
      end

      error ParameterMissingError do
        json_error 400
      end

      error Mongoid::Errors::DocumentNotFound do
        json_error 404, message: "The resource was not found"
      end

      error Mongoid::Errors::DuplicateKey do
        json_error 422
      end

      error Mongoid::Errors::UnknownAttribute do
        field = env['sinatra.error'].attr_name
        json_error 422,
          message: "The resource contains an unknown field: #{field}"
      end

      error Mongoid::Errors::Validations do
        json_error 422,
          message: "The data for the resource is incomplete or invalid"
      end

    end
  end
end

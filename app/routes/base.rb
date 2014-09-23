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

      error ParameterMissingError do
        json_error 400
      end

      error Mongoid::Errors::DocumentNotFound do
        json_error 404, message: "The resource was not found"
      end

      error Mongoid::Errors::UnknownAttribute do
        json_error 400, message: "The provided data is invalid"
      end

      error Mongoid::Errors::Validations do
        json_error 400, message: "The provided data is incomplete or malformed"
      end

    end
  end
end

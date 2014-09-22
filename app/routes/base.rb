module Academical
  module Routes
    class Base < Sinatra::Base

      configure do
        set :root, Api.root
        set :views, 'app/views'

        disable :raise_errors
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
        raise env['sinatra.error'] if settings.test?
        json_error 500
      end

      error ParameterMissingError do
        raise env['sinatra.error'] if settings.test?
        json_error 400
      end

      error Mongoid::Errors::DocumentNotFound do
        raise env['sinatra.error'] if settings.test?
        json_error 404, message: "The resource was not found"
      end

      error Mongoid::Errors::Validations do
        raise env['sinatra.error'] if settings.test?
        json_error 400, message: "The provided data is incomplete or malformed"
      end

    end
  end
end

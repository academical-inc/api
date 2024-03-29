#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

module Academical
  module Routes
    class Base < Sinatra::Base

      configure do
        set :root, Api.root
        set :views, 'app/views'
        set :api_content_type, 'application/json'
        set :api_charset, 'utf-8'
        set :cache, Api.global_cache

        enable :logging

        disable :dump_errors
        disable :show_exceptions
        disable :protection
      end

      configure do
        register Sinatra::CrossOrigin
        enable :cross_origin
        set :allow_methods, [:get, :post, :put, :delete, :options]
      end

      configure :production do
        set :haml, { :ugly=>true }
        set :clean_trace, true
      end

      helpers ResponseUtils
      helpers CommonHelpers
      helpers ResourceHelpers
      helpers AuthHelpers
      helpers SectionDemandHelpers

      before do
        halt 200 if request.options?
        Bugsnag.before_notify_callbacks << lambda {|notif|
          notif.add_tab(:env, request.env)
          notif.add_tab(:user, current_student.as_json)
        }
        if request.post? or request.put?
          if !request.content_type.include? settings.api_content_type
            json_error 400,
              message: "The request Content-Type must be application/json. Received #{request.content_type}"
          end
        end
      end

      after do
        # Properly clear any before_notify_callbacks set before handling the request
        Bugsnag.before_notify_callbacks.clear
      end

      error do
        dump_errors! env['sinatra.error']
        Bugsnag.auto_notify($!)
        json_error 500
      end

      not_found do
        json_error 404, message: "The requested path is unknown"
      end

      error ParameterMissingError do
        Bugsnag.notify env['sinatra.error']
        json_error 400, message: env['sinatra.error'].message
      end

      error InvalidParameterError do
        Bugsnag.notify env['sinatra.error']
        json_error 400, message: env['sinatra.error'].message
      end

      error InvalidTokenError do
        Bugsnag.notify env['sinatra.error']
        json_error 401, message: env['sinatra.error'].message
      end

      error NotAuthorizedError do
        Bugsnag.notify env['sinatra.error']
        error = env['sinatra.error']
        json_error error.code, message: error.message
      end

      error Mongoid::Errors::DocumentNotFound do
        Bugsnag.notify env['sinatra.error']
        json_error 404, message: "The resource was not found"
      end

      error Mongoid::Errors::DocumentsNotFound do
        ex = env['sinatra.error']
        Bugsnag.notify ex
        json_error 404, message: ex.message, data: ex.found
      end

      error Mongoid::Errors::DuplicateKey do
        Bugsnag.notify env['sinatra.error']
        json_error 422, message: env['sinatra.error'].message
      end

      error Mongoid::Errors::UnknownAttribute do
        Bugsnag.notify env['sinatra.error']
        field = env['sinatra.error'].attr_name
        json_error 422,
          message: "The resource contains an unknown field: #{field}"
      end

      error Mongoid::Errors::Validations do
        Bugsnag.notify env['sinatra.error']
        errors = env['sinatra.error'].document.errors.full_messages
        json_error 422,
          message: "The data for the resource is incomplete or invalid",
          errors: errors
      end

    end
  end
end

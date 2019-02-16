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
  module Exceptions
    class MethodMissingError < StandardError; end
    class InvalidFrequencyError < StandardError; end
    class InvalidModelRouteError < StandardError
      def to_s
        %(
        Your routes class should be named as a plural of the corresponding
        model, and inherit from Base. e.g. "class Schools < Base", where the
        model is "School".
        You can also use a different name for your routes class. To do so
        override the class method .model and return the appropriate model class
        associated with your routes.
        )
      end
    end
    class ParameterMissingError < StandardError
      def initialize(key)
        @key = key
      end

      def to_s
        "Required param '#{@key}' is missing from the request"
      end
    end
    class InvalidParameterError < StandardError
      def initialize(key)
        @key = key
      end

      def to_s
        "Required param '#{@key}' is invalid"
      end
    end
    class NotAuthorizedError < StandardError
      attr_reader :code
      def initialize(code)
        @code = code
      end

      def to_s
        case @code
        when 404
          'The resource was not found'
        when 403
          'Not authorized'
        end
      end
    end
    class InvalidTokenError < StandardError
      def to_s
        'Invalid credentials. Please try again.'
      end
    end
    class TokenValidationError < StandardError; end
    class InvalidTokenIssuerError < TokenValidationError
      def initialize(issuer)
        @issuer = issuer
      end

      def to_s
        "Token issued by an unexpected issuer: #{@issuer}"
      end
    end
    class IncompleteTokenPayload < TokenValidationError
      def initialize(key)
        @key = key
      end

      def to_s
        "Token payload missing required parameter: #{@key}"
      end
    end
  end
end

include Academical::Exceptions

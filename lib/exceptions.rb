module Academical
  module Exceptions
    class MethodMissingError < StandardError; end
    class InvalidFrequencyError < StandardError; end
    class InvalidModelRouteError < StandardError
      def to_s
        %Q[
        Your routes class should be named as a plural of the corresponding
        model, and inherit from Base. e.g. "class Schools < Base", where the
        model is "School".
        You can also use a different name for your routes class. To do so
        override the class method .model and return the appropriate model class
        associated with your routes.
        ]
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
    class InvalidTokenError < StandardError
      def to_s
        "Invalid credentials. Please try again."
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
          "The resource was not found"
        when 403
          "Not authorized"
        end
      end
    end
  end
end

include Academical::Exceptions

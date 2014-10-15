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
        "Required data '#{@key}' is missing from the request"
      end
    end
  end
end

include Academical::Exceptions

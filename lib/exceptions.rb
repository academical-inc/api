module Academical
  module Exceptions
    class MethodMissingError < StandardError; end
    class InvalidFrequencyError < StandardError; end
    class ParameterMissingError < StandardError
      def initialize(key)
        @key = key
      end

      def to_s
        "The parameter '#{@key}' is missing from the request"
      end
    end
  end
end

include Academical::Exceptions

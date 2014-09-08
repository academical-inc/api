module Academical
  module Exceptions
    class MethodMissingError < StandardError; end
    class InvalidFrequencyError < StandardError; end
  end
end

include Academical::Exceptions

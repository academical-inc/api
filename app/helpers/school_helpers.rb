module Academical
  module Helpers
    module SchoolHelpers

      def create_school(params)
        @school = School.create! params
      rescue Mongoid::Errors::Validations
        halt 400, json({:status => "failed"})
      end

    end
  end
end

module Academical
  module Helpers
    module SchoolHelpers

      module_function

      def schools(where: nil, count: contains?(:count))
        res = School.where(where)
        if count == true
          res.count
        else
          res
        end
      end

      def school(id=extract!(:school_id))
        School.find(id)
      end

      def create_school(data=extract!(:data))
        School.create! data
      end

    end
  end
end

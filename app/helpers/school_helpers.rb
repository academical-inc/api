module Academical
  module Helpers
    module SchoolHelpers

      module_function

      def schools(where: nil, count: contains?(:count))
        res = School.where(where)
        get_result(res, count)
      end

      def school(id=extract!(:school_id))
        School.find(id)
      end

      def school_rel(field, id: extract!(:school_id), count: contains?(:count))
        res = school(id).send(field.to_sym)
        get_result(res, count)
      end

      def create_school(data=extract!(:data))
        School.create! data
      end

      def upsert_school(data=extract!(:data))
        # TODO
      end

    end
  end
end

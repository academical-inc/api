module Academical
  module Helpers
    module SchoolHelpers

      def schools(where: nil)
        School.all if where.blank?
        School.where(where)
      end

      def school(id: params[:school_id])
        @school ||= School.find(id)
      end

      def create_school(data: extract!(:data))
        School.create! data
      end

    end
  end
end

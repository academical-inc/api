module Academical
  module Helpers
    module SchoolHelpers

      def schools(where: nil)
        School.all if where.blank?
        School.where(where)
      end

      def school(id: params[:school_id])
        @school ||= School.find(id) || halt(404, "Not Found! :)")
      end

      def create_school(params)
        School.create! params
      rescue Mongoid::Errors::Validations
        halt 400, json({:status => "failed"})
      end

    end
  end
end

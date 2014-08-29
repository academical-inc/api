module Academical
  module Models

    class SchoolTerm

      include Mongoid::Document

      field :name
      field :start_date, type: Date
      field :end_date, type: Date

      validates_presence_of :name, :start_date, :end_date
      validate :check_dates_are_correct

      embedded_in :school, inverse_of: :terms

      def dates_correct?
        start_date < end_date
      end

      def check_dates_are_correct
        errors.add(:start_date, "can't be greater than end_date") \
          if not dates_correct?
      end

    end
  end
end

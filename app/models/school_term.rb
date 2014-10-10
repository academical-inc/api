module Academical
  module Models
    class SchoolTerm

      include Mongoid::Document

      field :name, type: String
      field :start_date, type: Date
      field :end_date, type: Date

      validates_presence_of :name, :start_date, :end_date
      validate :dates_are_correct

      embedded_in :school, inverse_of: :terms

      def dates_are_correct
        if start_date.blank?
          errors.add(:start_date, "can't be blank")
        elsif end_date.blank?
          errors.add(:end_date, "can't be blank")
        else
          errors.add(:start_date, "can't be greater than or equal to end_date") \
            if start_date >= end_date
        end
      end

    end
  end
end

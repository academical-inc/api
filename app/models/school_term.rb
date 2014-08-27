module Academical
  module Models

    class SchoolTerm

      include Mongoid::Document

      field :name
      field :start_date, type: Date
      field :end_date, type: Date

      validates_presence_of :name, :start_date, :end_date
      validate :dates_correct?

      embedded_in :school, inverse_of: :terms

      def dates_correct?
        start_date < end_date
      end

    end
  end
end

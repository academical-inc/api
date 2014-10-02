module Academical
  module Models
    class Name

      include Mongoid::Document

      field :first, type: String
      field :middle, type: String
      field :last, type: String
      field :other, type: String

      embedded_in :student
      embedded_in :teacher

      validates_presence_of :first, :last

      def full_name(include_other: false, truncate: true, trunc_length: 35)
        full_name = first.dup
        full_name << " #{middle}" if not middle.blank?
        full_name << " #{last}"
        full_name << " #{other}" if include_other and not other.blank?
        full_name = full_name.truncate(trunc_length) if truncate
        full_name
      end

    end
  end
end

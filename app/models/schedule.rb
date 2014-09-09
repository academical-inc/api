module Academical
  module Models
    class Schedule

      include Mongoid::Document
      include Mongoid::Timestamps
      include Linkable

      field :name, type: String
      field :total_sections, type: Integer
      field :total_credits,  type: Float
      field :share_id, type: String
      embeds_one  :term, class_name: "SchoolTerm"
      embeds_many :personal_events, class_name: "Event"
      belongs_to  :school, index: true
      belongs_to  :student, index: true
      has_and_belongs_to_many :sections, index: true

      def linked_fields
        [:student, :sections, :school]
      end

    end
  end
end

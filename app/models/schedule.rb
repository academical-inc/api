module Academical
  module Models
    class Schedule

      include Mongoid::Document
      include Mongoid::Timestamps
      include Linkable

      field :name, type: String
      field :total_credits,  type: Float
      field :total_sections, type: Integer
      field :share_id, type: String
      embeds_one  :term, class_name: "SchoolTerm"
      embeds_many :personal_events, class_name: "Event"
      belongs_to  :school, index: true
      belongs_to  :student, index: true
      has_and_belongs_to_many :sections, index: true

      validates_presence_of :name, :total_credits, :total_sections, :term,
                            :school, :student

      index({name: 1})
      index({total_credits: 1})
      index({total_sections: 1})
      index({school: 1, name:1})
      index({school: 1, total_credits: 1})
      index({school: 1, total_sections: 1})
      index({:school=>1, "personal_events.name"=>1}, {sparse: true})

      def linked_fields
        [:student, :sections, :school]
      end

    end
  end
end

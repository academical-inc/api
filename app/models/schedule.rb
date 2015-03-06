module Academical
  module Models
    class Schedule

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      attr_accessor :include_sections

      field :name, type: String
      field :total_credits,  type: Float, default: 0
      field :total_sections, type: Integer, default: 0
      field :share_id, type: String
      field :section_colors, type: Hash
      embeds_one  :term, class_name: "SchoolTerm"
      embeds_many :personal_events, class_name: "Event"
      belongs_to  :school, index: true
      belongs_to  :student, index: true, inverse_of: :schedules
      has_and_belongs_to_many :sections, index: true

      validates_presence_of :name, :total_credits, :total_sections, :term,
                            :school, :student

      index({name: 1})
      index({total_credits: 1})
      index({total_sections: 1})
      index({share_id: 1})
      index({school: 1, name:1})
      index({school: 1, total_credits: 1})
      index({school: 1, total_sections: 1})
      index({:school=>1, "personal_events.name"=>1}, {sparse: true})

      def self.linked_fields
        [:student, :sections, :school]
      end

      def as_json(options=nil)
        options ||= {}
        if @include_sections == true
          if options[:methods].is_a? Array
            options[:methods].push :sections
          else
            options[:methods] = :sections
          end
        end
        super options
      end

    end
  end
end

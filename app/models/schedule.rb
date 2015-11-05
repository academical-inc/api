module Academical
  module Models
    class Schedule

      MAX_NAME_LENGTH = 60

      include Mongoid::Document
      include Mongoid::Timestamps
      include Mongoid::CachedJson
      include IndexedDocument
      include Linkable

      field :name, type: String
      field :total_credits,  type: Float, default: 0
      field :total_sections, type: Integer, default: 0
      field :section_colors, type: Hash, default: {}
      field :public, type: Boolean, default: true
      # TODO Test
      field :term, type: String
      embeds_many :events, cascade_callbacks: true
      belongs_to  :school, index: true
      belongs_to  :student, index: true, inverse_of: :schedules
      has_and_belongs_to_many :sections, index: true, inverse_of: nil

      validates_presence_of :name, :total_credits, :total_sections, :term,
                            :school, :student
      validates_length_of :name, minimum: 1, maximum: MAX_NAME_LENGTH
      # TODO Test
      validate :same_school, :term_valid

      index({name: 1})
      index({total_credits: 1})
      index({total_sections: 1})
      index({term: 1})
      index({student_id: 1, created_at: 1})
      index({school: 1, name:1})
      index({school: 1, total_credits: 1})
      index({school: 1, total_sections: 1})
      index({:student=>1, :term=>1})
      index({:school=>1, :student=>1, :term=>1})
      index({:school=>1, :term=>1})

      json_fields \
        id: {},
        name: {},
        total_credits: {},
        total_sections: {},
        section_colors: {},
        public: {},
        term: {},
        events: { type: :reference },
        school_id: {},
        student_id: {},
        section_ids: {},
        sections: { type: :reference, properties: :short, reference_properties: :short }

      def same_school
        if school != student.school
          errors.add("school", "must be the same as student's")
        end
      end

      def term_valid
        if not school.terms.index { |t| t.name == term }
          errors.add("term", "must be one of the school's terms")
        end
      end

      # TODO Test
      def to_ical
        cal = Icalendar::Calendar.new
        sections.each do |sec|
          sec.events.each do |sec_event|
            cal.add_event sec_event.to_ical
          end
        end

        events.each do |event|
          cal.add_event event.to_ical
        end

        cal.publish
        cal.to_ical
      end

      def self.linked_fields
        [:sections, :events]
      end

    end
  end
end

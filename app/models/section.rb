module Academical
  module Models
    class Section

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      field :course_name, type: String
      field :course_description, type: String
      field :course_code, type: String
      field :section_id, type: String
      field :section_number, type: String
      field :teacher_names, type: Array
      field :custom, type: Hash
      field :credits, type: Float
      field :seats, type: Hash
      embeds_one :term, class_name: "SchoolTerm"
      embeds_many :events, cascade_callbacks: true
      embeds_many :departments
      has_many :corequisites, class_name: "Section", inverse_of: :corequisite_of
      belongs_to :corequisite_of,
                 class_name: "Section",
                 inverse_of: :corequisites,
                 index: true
      belongs_to :school, index: true
      has_and_belongs_to_many :schedules, index: true
      has_and_belongs_to_many :prerequisites, class_name: "Section", index: true
      has_and_belongs_to_many :teachers, index: true, autosave: true

      before_save :update_teacher_names

      validates_presence_of :course_name, :credits, :seats, :term, :course_code,
                            :section_id, :departments, :school, :section_number

      index({course_name: 1})
      index({school: 1, course_name: 1})
      index({school: 1, course_code: 1})
      index({school: 1, section_id: 1}, {unique: true})
      index({:school=> 1, "term.name"=> 1})
      index({:school=> 1, "departments.name"=> 1})
      index({:school=> 1, "departments.faculty_name"=> 1}, {sparse: true})
      index({:school=> 1, "events.recurrence.days_of_week"=> 1}, {sparse: true})
      index({:school=> 1, "events.start_dt"=> 1}, {sparse: true})
      index({:school=> 1, "events.end_dt"=> 1}, {sparse: true})
      index({:school=> 1, "events.location"=> 1}, {sparse: true})


      def update_teacher_names
        self.teacher_names = teachers.map { |teacher| teacher.full_name }
      end

      def expand_events
        events.each do |event|
          event.expand
        end
      end

      def students
        # TODO
      end

      def self.linked_fields
        [:teachers, :students, :schedules, :school]
      end

    end
  end
end

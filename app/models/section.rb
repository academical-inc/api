module Academical
  module Models
    class Section

      include Mongoid::Document
      include Mongoid::Timestamps
      include Linkable

      field :name, type: String
      field :section_id, type: String
      field :teacher_names, type: Array
      field :custom, type: Hash
      field :credits, type: Float
      field :seats, type: Hash
      embeds_one :course
      embeds_one :term, class_name: "SchoolTerm"
      embeds_many :events
      embeds_many :departments
      has_many :corequisites, class_name: "Section", inverse_of: :corequisite_of
      belongs_to :corequisite_of,
                 class_name: "Section",
                 inverse_of: :corequisites,
                 index: true
      belongs_to :school, index: true
      has_and_belongs_to_many :teachers, index: true

      validates_presence_of :name, :credits, :seats, :course, :term, :events,
                            :departments, :school, :teachers, :section_id

      index({name: 1})
      index({school: 1, name: 1})
      index({school: 1, section_id: 1}, {unique: true})
      index({:school=> 1, "departments.name"=> 1})
      index({:school=> 1, "departments.faculty_name"=> 1}, {sparse: true})
      index({:school=> 1, "course.code"=> 1})
      index({:school=> 1, "events.days_of_week"=> 1})
      index({:school=> 1, "events.start_time"=> 1})
      index({:school=> 1, "events.end_time"=> 1})
      index({:school=> 1, "events.location"=> 1})

      def linked_fields
        [:teachers, :students, :schedules]
      end

    end
  end
end

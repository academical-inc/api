module Academical
  module Models
    class Section

      AWS_BUCKET = ENV['AWS_BUCKET']
      DUMP_NAME  = 'magistral_sections.json'

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      field :course_name, type: String
      field :course_description, type: String
      field :course_code, type: String
      field :section_id, type: String
      field :section_number, type: String
      field :custom, type: Hash
      field :credits, type: Float
      field :seats, type: Hash
      embeds_one :term, class_name: "SchoolTerm"
      embeds_many :events, cascade_callbacks: true
      embeds_many :departments
      has_many :corequisites,
               class_name: "Section",
               inverse_of: :corequisite_of
      belongs_to :corequisite_of,
                 class_name: "Section",
                 inverse_of: :corequisites,
                 index: true
      has_and_belongs_to_many :schedules, index: true
      has_and_belongs_to_many :teachers, index: true
      has_and_belongs_to_many :prerequisites,
                              class_name: "Section",
                              index: true
      belongs_to :school, index: true

      validate :either_has_corequisites_or_is_corequisite
      validates_presence_of :course_name, :credits, :seats, :term, :course_code,
                            :section_id, :departments, :school, :section_number

      before_create :titleize_fields

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

      scope :magistrals, ->{ where(corequisite_of: nil) }

      def serializable_hash(options = nil)
        attrs = super(options)
        attrs["teacher_names"] = teachers.map { |teacher| teacher.full_name }
        attrs
      end

      def either_has_corequisites_or_is_corequisite
        if (not corequisite_of.blank?) and (not corequisites.blank?)
          errors.add(
            :corequisites,
            "Section cannot be a correquisite and have correquisites at the " +
            "same time"
          )
        end
      end

      def titleize_fields
        self.course_name = CommonHelpers.titleize course_name
        departments.each do |department|
          department.name = CommonHelpers.titleize department.name
        end
      end

      def expand_events
        events.each do |event|
          event.expand
        end
      end

      def students
        # TODO
      end

      def self.dump_magistrals(school)
        sections = Section.magistrals.map do |section|
          CommonHelpers.camelize_hash_keys(
            section.as_json(methods: [:corequisites])
          )
        end
        sections = sections.to_json

        s3 = AWS::S3.new
        bucket = s3.buckets[AWS_BUCKET]
        bucket.objects["#{school}/#{DUMP_NAME}"].write(sections)
      end

      def self.linked_fields
        [:teachers, :students, :schedules, :school]
      end

    end
  end
end

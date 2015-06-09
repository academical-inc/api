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

      before_validation :init_fields

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
        options ||= {}
        if options[:methods].is_a? Array
          options[:methods].push :corequisites
        else
          options[:methods] = [:corequisites]
        end
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

      def init_fields
        titleize_fields
        set_events_name
      end

      def titleize_fields
        self.course_name = CommonHelpers.titleize course_name
        departments.each do |department|
          department.name = CommonHelpers.titleize department.name
        end
      end

      def set_events_name
        if not events.blank?
          events.each do |event|
            event.name = course_name if event.name.blank?
          end
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

      def self.dump_magistrals(school, dev=false)
        sections = Section.magistrals.select do |section|
          not section.events.blank?
        end
        sections = sections.map do |section|
          section.expand_events
          section.corequisites.each do |corequisite|
            corequisite.expand_events
          end
          CommonHelpers.camelize_hash_keys(
            section.as_json
          )
        end
        sections = sections.to_json
        name = "#{school}"
        name += "/dev" if dev
        name += "/#{DUMP_NAME}"

        s3 = AWS::S3.new
        bucket = s3.buckets[AWS_BUCKET]
        bucket.objects[name].write(sections)
      end

      def self.linked_fields
        [:teachers, :students, :schedules]
      end

    end
  end
end

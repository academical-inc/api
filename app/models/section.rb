module Academical
  module Models
    class Section

      AWS_BUCKET = ENV['AWS_BUCKET']
      NUM_THREADS = ENV['NUM_THREADS_DUMP'].to_i
      SEARCH_LIMIT = 50

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      searchkick callbacks: :async, language: "Spanish", text_start: [
        :course_name,
        :course_code,
        :section_id,
        :teacher_names,
        :departments
      ]

      field :course_name, type: String
      field :course_description, type: String
      field :course_code, type: String
      field :section_id, type: String
      field :section_number, type: String
      field :custom, type: Hash
      field :credits, type: Float
      field :seats, type: Hash
      field :teacher_names, type: Array, default: []
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
      index({school: 1, corequisite_of: 1})
      index({school: 1, section_id: 1}, {unique: true})
      index({:school=> 1, "term.name"=> 1})
      index({:school=> 1, "departments.name"=> 1})
      index({:school=> 1, "departments.faculty_name"=> 1}, {sparse: true})
      index({:school=> 1, "events.recurrence.days_of_week"=> 1}, {sparse: true})
      index({:school=> 1, "events.start_dt"=> 1}, {sparse: true})
      index({:school=> 1, "events.end_dt"=> 1}, {sparse: true})
      index({:school=> 1, "events.location"=> 1}, {sparse: true})

      scope :magistrals, ->(nickname){
        where(
          school: School.find_by(nickname: nickname), corequisite_of: nil
        )
      }

      def search_data
        {
          id: id,
          school: school.nickname,
          term: term.name,
          section_id: section_id,
          course_name: course_name,
          course_code: course_code,
          seats: seats,
          teacher_names: teacher_names,
          departments: departments.map { |dep| dep.name },
          corequisite_of: corequisite_of,
          custom: custom
        }
      end

      def serializable_hash(options = nil)
        options ||= {}
        if options[:methods].is_a? Array
          options[:methods].push :corequisites
        else
          options[:methods] = [:corequisites]
        end
        super(options)
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
        set_teacher_names
      end

      def titleize_fields
        self.course_name = CommonHelpers.titleize self.course_name
        self.departments.each do |department|
          department.name = CommonHelpers.titleize department.name
        end
      end

      def set_events_name
        if not self.events.blank?
          self.events.each do |event|
            event.name = course_name
          end
        end
      end

      def set_teacher_names
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

      def self.autocompl_search(query, school, term, filters=[])
        where = { school: school, term: term, corequisite_of: nil }
        filters.each do |filter|
          filter.deep_symbolize_keys!
          where.merge! filter
        end

        Section.search query, fields: [
          {course_name: :text_start},
          {course_code: :text_start},
          {section_id:  :text_start},
          {teacher_names: :text_start},
          {departments: :text_start}
        ], where: where, limit: SEARCH_LIMIT
      end

      def self.dump_magistrals(school)
        sections = Section.magistrals(school).to_a
        batch_size = sections.count / NUM_THREADS
        threads = []

        sections.each_slice(batch_size).with_index do |batch, idx|
          threads << Thread.new do
            batch.each_with_index do |section, i|
              actual = i + (idx*batch_size)
              section.expand_events
              section.corequisites.each do |corequisite|
                corequisite.expand_events
              end
              sections[actual] = CommonHelpers.camelize_hash_keys(
                section.as_json
              )
            end
          end
        end
        threads.each(&:join)
        puts "Finished expanding section events"

        name = "#{school}.json"
        sections = sections.to_json
        puts "Finished converting to json"

        s3 = AWS::S3.new
        bucket = s3.buckets[AWS_BUCKET]
        bucket.objects[name].write(sections, {
          acl: :public_read,
          cache_control: 'no-cache',
          content_type: 'application/json'
        })
        puts "Finished uploading to S3"
      end

      def self.linked_fields
        [:teachers, :students, :schedules]
      end

    end
  end
end

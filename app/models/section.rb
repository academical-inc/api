#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

module Academical
  module Models
    class Section

      AWS_BUCKET = ENV['AWS_BUCKET']
      NUM_THREADS = ENV['NUM_THREADS_DUMP'].to_i
      SEARCH_LIMIT = 30

      include Mongoid::Document
      include Mongoid::Timestamps
      include Mongoid::CachedJson
      include IndexedDocument
      include Linkable

      searchkick callbacks: :async, language: "Spanish", word_start: [
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
               inverse_of: :corequisite_of,
               dependent: :nullify
      belongs_to :corequisite_of,
                 class_name: "Section",
                 inverse_of: :corequisites,
                 index: true
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
      index({section_id: 1})
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

      json_fields \
        id: {},
        course_name: {},
        course_description: {},
        course_code: {},
        section_id: {},
        section_number: {},
        custom: {},
        credits: {},
        seats: {},
        teacher_names: {},
        term: { type: :reference },
        events: { type: :reference },
        departments: { type: :reference },
        demand: { definition: lambda{ |ins| ins.student_ids.count }, properties: :short, versions: [:vcesa] },
        corequisites: { type: :reference, properties: :public, reference_properties: :short },
        corequisite_of_id: {},
        corequisite_ids: {},
        teacher_ids: { properties: :all },
        school_id: { properties: :all }

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

      # TODO Test
      def student_ids
        @student_ids ||= begin
          model = SectionDemand.find_by section_id: self.id
          model.student_ids
        rescue Mongoid::Errors::DocumentNotFound
          []
        end
        @student_ids
      end

      def self.autocompl_search(query, school, term, filters=[])
        where = { school: school, term: term, corequisite_of: nil }
        filters.each do |filter|
          filter.deep_symbolize_keys!
          where.merge! filter
        end

        Section.search query, fields: [
          {course_name: :word_start},
          {course_code: :word_start},
          {section_id:  :word_start},
          {teacher_names: :word_start},
          {departments: :word_start}
        ], operator: "or", where: where, limit: SEARCH_LIMIT
      end

      def self.dump_magistrals(school)
        sections = Section.magistrals(school).to_a
        batch_size = sections.count / NUM_THREADS
        threads = []

        sections.each_slice(batch_size).with_index do |batch, idx|
          threads << Thread.new do
            batch.each_with_index do |section, i|
              actual = i + (idx*batch_size)
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
        [:teachers]
      end

    end
  end
end

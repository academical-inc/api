module Academical
  module Models
    class Student

      MAX_SCHEDULES = 7

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      field :name, type: String
      field :auth0_user_id, type: String
      field :email, type:String
      field :student_number, type: String
      field :picture, type: String
      belongs_to :school, index: true
      belongs_to :registered_schedule, class_name: "Schedule", inverse_of: nil
      has_many   :schedules, order: :created_at.asc, dependent: :destroy do
        # TODO Test
        def latest
          term = @base.school.terms.latest.name
          @target.select { |schedule| schedule.term == term }
        end
      end

      index({auth0_user_id: 1}, {unique: true, name: "auth0_user_id_index"})
      index({email: 1}, {name: "email_index"})

      validates_presence_of :auth0_user_id, :email, :school
      validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
      validate :schedules_within_limit

      after_create :create_default_schedule

      def create_default_schedule
        if schedules.empty?
          Schedule.create!(
            name: I18n.t("schedule.default_name", locale: school.locale),
            student: self,
            school: school,
            term: school.terms.latest.name
          )
        end
      end

      def schedules_within_limit
        if schedules.latest.count > MAX_SCHEDULES
          errors.add("schedules",
                     "number for current term should not exceed #{MAX_SCHEDULES}")
        end
      end

      def has_section?(sec_id)
        self.schedules.each do |schedule|
          return true if schedule.section_ids.include? sec_id
        end
        false
      end

      def self.linked_fields
        [:schedules, :registered_schedule]
      end

    end
  end
end

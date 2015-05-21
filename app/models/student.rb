module Academical
  module Models
    class Student

      MAX_SCHEDULES = 7

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      field :username, type: String
      field :email, type:String
      field :student_number, type: String
      field :login_provider, type: String
      field :last_login, type: DateTime
      field :gender, type: String
      field :dob, type: Date
      embeds_one :location
      embeds_one :name
      belongs_to :school, index: true
      belongs_to :registered_schedule, class_name: "Schedule", inverse_of: nil
      has_many   :schedules, order: :created_at.asc

      index({username: 1}, {unique: true, name: "username_index"})
      index({email: 1}, {unique: true, name: "email_index"})

      validates_presence_of :username, :email, :last_login, :login_provider,
                            :school
      validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
      validates_length_of :schedules, maximum: MAX_SCHEDULES,
        too_long: "is too long (max number of schedules is #{MAX_SCHEDULES})"

      after_create :create_default_schedule

      def create_default_schedule
        if schedules.empty?
          Schedule.create!(
            name: I18n.t("schedule.default_name"),
            student: self,
            school: school,
            term: school.terms.latest_term
          )
        end
      end

      def self.linked_fields
        [:schedules, :registered_schedule]
      end

    end
  end
end

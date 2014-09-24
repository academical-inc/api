module Academical
  module Models
    class Student

      include Mongoid::Document
      include Mongoid::Timestamps
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
      has_many   :schedules

      index({username: 1}, {unique: true, name: "username_index"})
      index({email: 1}, {unique: true, name: "email_index"})

      validates_presence_of :username, :email, :last_login, :login_provider,
                            :school
      validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

      def self.linked_fields
        [:school, :schedules, :registered_schedule]
      end

    end
  end
end

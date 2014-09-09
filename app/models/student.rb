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
      has_many :schedules
      belongs_to :school, index: true

      index({username: 1}, {unique: true, name: "username_index"})
      index({email: 1}, {unique: true, name: "email_index"})

      validates_presence_of :username, :email, :last_login, :login_provider,
                            :school
      validates_format_of :email, :with => /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

      def linked_fields
        [:school, :schedules, :teachers, :sections]
      end

    end
  end
end

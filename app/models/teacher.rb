module Academical
  module Models
    class Teacher

      include Mongoid::Document
      include Mongoid::Timestamps
      include Linkable

      field :email
      field :title
      field :teacher_number
      embeds_one :name
      belongs_to :school, index: true
      has_and_belongs_to_many :sections, index: true

      validates_presence_of :name

      def full_name
        name.full_name
      end

      def self.linked_fields
        [:sections, :school]
      end

    end
  end
end

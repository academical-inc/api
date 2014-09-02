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

      index({name: 1}, {unique: true, name: "name_index"})

      validates_presence_of :name

      def linked_fields
        [:sections, :students, :school]
      end

    end
  end
end
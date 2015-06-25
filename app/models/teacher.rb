module Academical
  module Models
    class Teacher

      include Mongoid::Document
      include Mongoid::Timestamps
      include IndexedDocument
      include Linkable

      field :email, type: String
      field :title, type: String
      field :teacher_number, type: String
      embeds_one :name
      belongs_to :school, index: true
      has_and_belongs_to_many :sections, index: true

      validates_presence_of :name, :school
      after_save :reindex_sections

      index({:school => 1, "name.first" => 1, "name.middle" => 1,
             "name.last" => 1, "name.other" => 1}, {unique: true})

      def full_name
        name.full_name
      end

      def reindex_sections
        sections.each do |section|
          section.reindex
        end
      end

      def self.linked_fields
        [:sections]
      end

    end
  end
end

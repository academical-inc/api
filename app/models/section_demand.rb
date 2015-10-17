module Academical
  module Models
    class SectionDemand

      include Mongoid::Document

      field :section_id, type: String
      field :student_ids, type: Array, default: []

      index({section_id: 1}, {unique: true});
      index({student_ids: 1})

      validates_presence_of :section_id

    end
  end
end

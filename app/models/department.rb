module Academical
  module Models

    class Department

      include Mongoid::Document

      # Overriding _id since this will only be an embedded document
      field :_id, type: String, default: nil

      field :name
      field :faculty_name

      validates_presence_of :name

      embedded_in :school

    end

  end
end

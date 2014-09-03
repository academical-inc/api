module Academical
  module Models
    class Course

      include Mongoid::Document

      # Overriding _id since this will only be an embedded document
      field :_id, type: String, default: nil

      field :name, type: String
      field :description, type: String
      field :code, type: String

      validates_presence_of :name, :code

    end
  end
end

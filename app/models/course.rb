module Academical
  module Models
    class Course

      include Mongoid::Document

      field :name, type: String
      field :description, type: String
      field :code, type: String

      validates_presence_of :name, :code

    end
  end
end

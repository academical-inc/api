module Academical
  module Models

    class Department

      include Mongoid::Document

      field :name
      field :faculty_name

      validates_presence_of :name

      embedded_in :school

    end

  end
end

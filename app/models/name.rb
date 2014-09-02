module Academical
  module Models
    class Name

      include Mongoid::Document

      field :first
      field :middle
      field :last
      field :other

      embedded_in :student
      embedded_in :teacher

      validates_presence_of :first, :last

    end
  end
end

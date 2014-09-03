module Academical
  module Models
    class Name

      include Mongoid::Document

      # Overriding _id since this will only be an embedded document
      field :_id, type: String, default: nil

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

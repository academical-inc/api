module Academical
  module Models
    class Location

      include Mongoid::Document

      # Overriding _id since this will only be an embedded document
      field :_id, type: String, default: nil

      field :address
      field :city
      field :state
      field :postal_code
      field :country

      validates_presence_of :address, :city, :country

      embedded_in :student
      embedded_in :school

    end
  end
end

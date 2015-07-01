module Academical
  module Models
    class Location

      include Mongoid::Document

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

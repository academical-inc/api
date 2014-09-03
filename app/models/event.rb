module Academical
  module Models
    class Event

      include Mongoid::Document

      # Overriding _id since this will only be an embedded document
      field :_id, type: String, default: nil

      field :starts_on, type: Date
      field :ends_on, type: Date
      field :days_of_week, type: String
      field :start_time, type: Time
      field :end_time, type: Time
      field :location, type: String

      embedded_in :section

      validates_presence_of :starts_on, :ends_on, :days_of_week, :start_time,
                            :end_time, :location

    end
  end
end

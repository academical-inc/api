module Academical
  module Models
    class ExpandedEvent

      include Mongoid::Document

      field :start_dt, type: Time
      field :end_dt, type: Time
      field :location, type: String
      field :timezone, type: String

      def start_dt
        super.in_time_zone(self.timezone)
      end

      def end_dt
        super.in_time_zone(self.timezone)
      end

    end
  end
end

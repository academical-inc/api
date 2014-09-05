module Academical
  module Models
    class EventRecurrence

      include Mongoid::Document

      DAYS  = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
      FREQS = ["YEARLY", "MONTHLY", "WEEKLY", "DAILY", "HOURLY", "MINUTELY",
               "SECONDLY"]
      ISO_FORMAT = "%Y%m%dT%H%M%SZ"

      field :freq, type: String
      field :rr,  as: :rule, type: String
      field :dow, as: :days_of_week, type: Array
      field :ru,  as: :repeat_until, type: DateTime
      embedded_in :event

      before_create :update_rule

      validate :days_of_week_is_valid
      validates_inclusion_of :freq, in: FREQS
      validates_presence_of :freq, :repeat_until

      def days_of_week_is_valid
        if not days_of_week.blank?
          if days_of_week.length > DAYS.length or \
             (days_of_week - DAYS).length > 0
            errors.add(:days_of_week, "must contain valid days")
          end
        end
      end

      def update_rule
        until_utc = repeat_until.utc.strftime(ISO_FORMAT)
        self.rule = "RRULE:FREQ=#{freq};UNTIL=#{until_utc}"
        self.rule << ";BYDAY=#{days_of_week.join(",")}"\
          if not days_of_week.blank?
      end

    end
  end
end
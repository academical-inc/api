module Academical
  module Models
    class Event

      include Mongoid::Document

      field :sdt, as: :start_dt, type: DateTime
      field :edt, as: :end_dt, type: DateTime
      field :location, type: String
      embeds_one :recurrence, class_name: "EventRecurrence"

      embedded_in :section

      validates_presence_of :sdt, :edt, :location
      validate :recurrence_end_date_is_valid


      def expand
        # TODO
      end

      private

      def recurrence_end_date_is_valid
        has_recurrence = !(self.recurrence.blank?)

        if has_recurrence and \
            not DateUtils.same_time?(sdt, recurrence.repeat_until)
          errors.add("recurrence.repeat_until", \
                     "can't be different from event's start time")
        end
      end

    end
  end
end

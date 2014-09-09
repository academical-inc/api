module Academical
  module Models
    class Event

      include Mongoid::Document

      field :name, type: String
      field :description, type: String
      field :start_dt, type: DateTime
      field :end_dt, type: DateTime
      field :location, type: String
      field :timezone, type: String
      embeds_one :recurrence, class_name: "EventRecurrence"
      embedded_in :section
      embedded_in :schedule

      validates_presence_of :start_dt, :end_dt, :location
      validate :recurrence_end_date_is_valid

      def expand
        @expanded ||= generate_instances
      end

      def as_json(options={})
        attrs = super(options)
        attrs["expanded"] = @expanded if not @expanded.blank?
        attrs
      end

      private

      def generate_instances
        if self.has_recurrence?
          instances = []
          freq = self.recurrence.freq
          days = self.recurrence.days_of_week
          dt_until = self.recurrence.repeat_until

          generate_dates freq, dt_until, days: days do |sdt, edt|
            instances << build_instance_from_self(sdt, edt)
          end

          instances
        else
          [self]
        end
      end

      def generate_dates(freq, dt_until, days: nil, &block)
        incr = DateUtils.date_increment(freq)

        if freq.to_sym == DateUtils::WEEKLY and not days.blank?
          DateUtils.advance_dates self.start_dt, self.end_dt, dt_until, incr\
          do |dt_start, dt_end|
            generate_dates_by_days dt_start, dt_end, dt_until, days, &block
          end
        else
          DateUtils.advance_dates self.start_dt, self.end_dt, dt_until, incr\
          do |dt_start, dt_end|
            block.call(dt_start, dt_end)
          end
        end
      end

      def generate_dates_by_days(dt_start, dt_end, dt_until, days, &block)
        7.times do
          block.call(dt_start, dt_end)\
            if DateUtils.dt_day_included_in(dt_start, days) \
              and dt_start <= dt_until
          dt_start += 1.day
          dt_end   += 1.day
        end
      end

      def build_instance_from_self(sdt, edt)
        Event.new(start_dt: sdt, end_dt: edt, location: self.location)
      end

      def recurrence_end_date_is_valid
        if has_recurrence? and \
            not DateUtils.same_time?(self.start_dt, self.recurrence.repeat_until)
          errors.add("recurrence.repeat_until", \
                     "can't be different from event's start time")
        end
      end

    end
  end
end

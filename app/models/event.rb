module Academical
  module Models
    class Event

      include Mongoid::Document

      field :name, type: String
      field :description, type: String
      field :start_dt, type: Time
      field :end_dt, type: Time
      field :location, type: String
      field :timezone, type: String
      field :color, type: String
      embeds_one :recurrence, class_name: "EventRecurrence",
        cascade_callbacks: true
      embedded_in :section
      embedded_in :schedule

      validates_presence_of :start_dt, :end_dt, :name, :timezone
      validate :recurrence_end_date_is_valid, :timezone_is_valid

      def expand
        @expanded ||= generate_instances
      end

      def start_dt
        if timezone_is_valid and not super.blank?
          super.in_time_zone(self.timezone)
        else
          super
        end
      end

      def end_dt
        if timezone_is_valid and not super.blank?
          super.in_time_zone(self.timezone)
        else
          super
        end
      end

      def serializable_hash(options = nil)
        attrs = super(options)
        attrs["expanded"] = @expanded.as_json if not @expanded.blank?
        attrs
      end

      def recurrence_end_date_is_valid
        if has_recurrence? and not start_dt.blank? and\
            not recurrence.repeat_until.blank? and\
            not DateUtils.same_time?(start_dt, recurrence.repeat_until)
          errors.add("recurrence.repeat_until", \
                     "can't be different from event's start time")
        end
      end

      def timezone_is_valid
        if self.timezone.blank? or \
            ActiveSupport::TimeZone.new(self.timezone).blank?
          errors.add(:timezone, "must be a valid timezone")
          false
        else
          true
        end
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
          nil
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
        clone = self.dup
        clone.start_dt = sdt
        clone.end_dt   = edt
        clone
      end

    end
  end
end

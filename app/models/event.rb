#
# Copyright (C) 2012-2019 Academical Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

module Academical
  module Models
    class Event

      include Mongoid::Document

      field :name, type: String
      field :description, type: String
      field :start_dt, type: Time
      field :end_dt, type: Time
      field :location, type: String, default: ""
      field :timezone, type: String
      field :color, type: String
      embeds_one :recurrence, class_name: "EventRecurrence", cascade_callbacks: true
      embedded_in :section
      embedded_in :schedule

      validates_presence_of :start_dt, :end_dt, :name, :timezone
      validate :recurrence_end_date_is_valid, :timezone_is_valid

      def expand
        self.expanded = generate_instances
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
        options ||= {}
        if options[:methods].is_a? Array
          options[:methods].push :id
        else
          options[:methods] = [:id]
        end
        super(options)
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

      # TODO Test
      def to_ical
        ev = Icalendar::Event.new
        ev.dtstart  = start_dt
        ev.dtend    = end_dt
        ev.summary  = name
        ev.rrule    = recurrence.rule if not recurrence.rule.blank?
        ev.location = location if not location.blank?
        ev
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
        ExpandedEvent.new(
          start_dt: sdt, end_dt: edt, location: self.location,
          timezone: self.timezone
        )
      end

    end
  end
end

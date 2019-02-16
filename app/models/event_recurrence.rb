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
    class EventRecurrence

      include Mongoid::Document

      DAYS  = DateUtils.days_to_s
      FREQS = DateUtils.freqs_to_s
      ISO_FORMAT = "%Y%m%dT%H%M%SZ"

      field :freq, type: String
      field :rule, type: String
      field :days_of_week, type: Array
      field :repeat_until, type: Time
      embedded_in :event

      before_create :update_rule

      validate :days_of_week_is_valid
      validates_inclusion_of :freq, in: FREQS
      validates_presence_of :freq, :repeat_until

      def repeat_until
        if event.timezone_is_valid and not super.blank?
          super.in_time_zone(event.timezone)
        else
          super
        end
      end

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

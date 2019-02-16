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
  module Utils
    module DateUtils

      # Days of the week
      MO = :MO
      TU = :TU
      WE = :WE
      TH = :TH
      FR = :FR
      SA = :SA
      SU = :SU

      # Frequencies
      YEARLY   = :YEARLY
      MONTHLY  = :MONTHLY
      WEEKLY   = :WEEKLY
      DAILY    = :DAILY
      HOURLY   = :HOURLY
      MINUTELY = :MINUTELY
      SECONDLY = :SECONDLY

      DAYS  = [MO, TU, WE, TH, FR, SA, SU]
      FREQS = [YEARLY, MONTHLY, WEEKLY, DAILY]

      module_function

      def freqs_to_s
        FREQS.map { |freq| freq.to_s }
      end

      def days_to_s
        DAYS.map { |day| day.to_s }
      end

      def same_time?(t1, t2)
        t1, t2 = t1.utc, t2.utc
        t1.hour == t2.hour and t1.min == t2.min and t1.sec == t2.sec
      end

      def advance_dates(dt_start, dt_end, dt_until, incr, &block)
        while dt_start <= dt_until
          block.call(dt_start, dt_end)
          dt_start += incr
          dt_end   += incr
        end
      end

      def date_increment(freq)
        case freq.to_sym
        when YEARLY
          1.year
        when MONTHLY
          1.month
        when WEEKLY
          1.week
        when DAILY
          1.day
        when HOURLY
          1.hour
        when MINUTELY
          1.minute
        when SECONDLY
          1.second
        else
          raise InvalidFrequencyError, "The frequency #{freq} is invalid"
        end
      end

      def dt_day_included_in(dt, days)
        days = days.map { |day| day.to_sym }
        case
        when dt.monday?
          days.include? MO
        when dt.tuesday?
          days.include? TU
        when dt.wednesday?
          days.include? WE
        when dt.thursday?
          days.include? TH
        when dt.friday?
          days.include? FR
        when dt.saturday?
          days.include? SA
        when dt.sunday?
          days.include? SU
        else
          false
        end
      end

    end
  end
end

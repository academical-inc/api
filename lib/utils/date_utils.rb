module Academical
  module Utils
    class DateUtils

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

      def self.freqs_to_s
        FREQS.map { |freq| freq.to_s }
      end

      def self.days_to_s
        DAYS.map { |day| day.to_s }
      end

      def self.same_time?(t1, t2)
        t1, t2 = t1.utc, t2.utc
        t1.hour == t2.hour and t1.min == t2.min and t1.sec == t2.sec
      end

      def self.advance_dates(dt_start, dt_end, dt_until, incr, &block)
        while dt_start <= dt_until
          block.call(dt_start, dt_end)
          dt_start += incr
          dt_end   += incr
        end
      end

      def self.date_increment(freq)
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

      def self.dt_day_included_in(dt, days)
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

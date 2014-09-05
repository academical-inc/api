module Academical
  module Utils
    class DateUtils

      def self.same_time?(t1, t2)
        t1, t2 = t1.utc, t2.utc
        t1.hour == t2.hour and t1.min == t2.min and t1.sec == t2.sec
      end

    end
  end
end

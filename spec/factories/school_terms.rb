FactoryGirl.define do

  factory :school_term do
    ignore do
      year 2015
      month 1
      invalid false
    end
    start_date { Date.new(year, month, 15) }
    end_date {
      d = start_date + 4.months
      d -= 1.year if invalid
      d
    }
    name { "#{start_date.year}-#{if month==1 then 1 else 2 end}" }
  end

end

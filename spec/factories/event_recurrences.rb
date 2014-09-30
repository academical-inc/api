FactoryGirl.define do

  factory :event_recurrence do

    ignore do
      start_dt DateTime.new(2015,1,15,11,0).utc
    end

    freq "WEEKLY"
    repeat_until { (start_dt + 4.months).utc }

    trait :with_days do
      days_of_week ["MO", "WE"]
    end

  end
end


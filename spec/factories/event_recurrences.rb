FactoryGirl.define do

  factory :event_recurrence do

    ignore do
      start_dt DateTime.parse("20140115T110000Z")
    end

    event { build(:event, :with_section) }

    freq "WEEKLY"
    repeat_until { start_dt + 4.months }

    trait :with_days do
      days_of_week ["MO", "WE"]
    end

  end
end


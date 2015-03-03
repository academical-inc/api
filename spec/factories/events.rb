FactoryGirl.define do

  sequence(:pev_name) { |n| "Event #{n}" }

  factory :event do
    start_dt Time.new(2015,1,15,11,0).utc
    end_dt Time.new(2015,1,15,12,30).utc

    location "Somewhere on earth"
    timezone "America/Bogota"
    name     { generate :pev_name }

    trait :with_recurrence do
      recurrence { build(:event_recurrence, :with_days, start_dt: start_dt) }
    end

    trait :with_section do
      section { build(:section) }
    end
  end

end

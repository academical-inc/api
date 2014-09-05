FactoryGirl.define do

  factory :event do
    start_dt DateTime.new(2015,1,15,11,0)
    end_dt DateTime.new(2015,1,15,12,30)

    location "Somewhere on earth"

    trait :with_recurrence do
      recurrence { build(:event_recurrence) }
    end

    trait :with_section do
      section { build(:section) }
    end
  end

end

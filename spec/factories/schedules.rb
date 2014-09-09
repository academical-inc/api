FactoryGirl.define do

  factory :schedule do
    name "My first schedule"
    total_credits 6.0
    total_sections 2
    term { build(:school_term) }
    school { build(:school) }
    student { build(:student) }

    trait :with_events do
      personal_events { build_list(:event, 3, name: "My event") }
    end

    trait :with_sections do
      sections { build_list(:section, 2) }
    end
  end
end

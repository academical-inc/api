FactoryGirl.define do

  factory :schedule do
    name "My first schedule"
    total_credits 6.0
    total_sections 2
    term { build(:school_term) }
    student { build(:student) }
    school { student.school }
    personal_events { build_list(:event, 3, name: "My event") }
    sections { build_list(:section, 2) }
  end
end

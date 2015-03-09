FactoryGirl.define do

  factory :schedule do
    name "My first schedule"
    total_credits 6.0
    total_sections 2
    term { build(:school_term) }
    student { build(:student) }
    school { student.school }
    events { build_list(:event, 2, :with_recurrence) }
    sections { build_list(:section, 2, :with_events) }
    after(:create) do |schedule|
      schedule.student.save!
      schedule.sections.each { |section| section.save }
    end
  end
end

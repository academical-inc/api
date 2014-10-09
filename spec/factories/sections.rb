FactoryGirl.define do

  sequence :section_id

  factory :section do
    course_name "Algebra"
    course_code "MATH1205"
    section_id
    section_number "1"
    credits 3.0
    seats {
      {
        available: 10,
        total: 25,
        taken: 15
      }
    }
    term { build(:school_term) }
    departments { build_list(:department, 2) }
    school { build(:school) }

    trait :with_events do
      events { build_list(:event, 3, :with_recurrence) }
    end

    trait :with_teachers do
      teachers { create_list(:teacher, 2, school: school) }
    end

    trait :with_teacher_names do
      teacher_names ["John Doe", "Paul McCartney"]
    end

  end
end

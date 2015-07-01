FactoryGirl.define do

  sequence(:dept_name) { |n| "Department_#{n}" }
  sequence(:fact_name) { |n| "Faculty_#{n}" }

  factory :department do
    name         { generate :dept_name }
    faculty_name { generate :fact_name }
  end

end

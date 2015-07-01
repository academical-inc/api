FactoryGirl.define do

  sequence(:first)  { |n| "John_#{n}" }
  sequence(:middle) { |n| "Paul_#{n}" }
  sequence(:last)   { |n| "Doe_#{n}" }
  sequence(:other)  { |n| "Prada_#{n}" }

  factory :name do
    first
    middle
    last
    other
  end

end

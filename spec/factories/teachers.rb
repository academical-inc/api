FactoryGirl.define do

  factory :teacher do
    name { build(:name) }
  end

end

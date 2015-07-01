FactoryGirl.define do

  factory :teacher do
    name { build(:name) }
    school { build(:school) }
  end

end

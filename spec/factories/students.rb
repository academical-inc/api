FactoryGirl.define do

  sequence(:auth0_user_id) { |n| "user#{n}" }

  factory :student do
    auth0_user_id { generate :auth0_user_id }
    email { "#{auth0_user_id}@gmail.com" }
    school { build(:school) }
  end

end

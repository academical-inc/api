FactoryGirl.define do

  sequence(:username) { |n| "user#{n}" }

  factory :student do
    username { generate :username }
    email { "#{username}@gmail.com" }
    last_login Date.new(2015, 1, 1)
    login_provider "Google"
    school { build(:school) }
  end

end

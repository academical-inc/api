FactoryGirl.define do

  factory :student do
    username "user1"
    email "user1@gmail.com"
    last_login Date.new(2015, 1, 1)
    login_provider "Google"
  end

end

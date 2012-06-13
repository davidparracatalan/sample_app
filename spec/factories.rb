FactoryGirl.define do
  factory :user do
    name       "User Test"
    email      "testuser@factorygirlfake.test"
    password   "password"
    password_confirmation "password"
  end
end
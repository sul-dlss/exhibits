# This will guess the User class
FactoryGirl.define do
  factory :user do
    email                  "user@example.com"
    password               "password"
    password_confirmation  "password"
  end

  factory :curator, class: User do
    email                  "curator@example.com"
    password               "password"
    password_confirmation  "password"
    after(:build)  { |user| user.webauth_groups = "dlss:exhibits-creators" }
  end
  
  factory :admin, class: User do
    email                  "admin@example.com"
    password               "password"
    password_confirmation  "password"
    after(:build)  { |user| user.webauth_groups = "dlss:exhibits-admin" }
  end
end
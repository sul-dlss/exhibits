# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :curator, class: 'User' do
    sequence(:email) { |n| "curator#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    after(:build) { |user| user.webauth_groups = 'dlss:exhibits-creators' }
  end

  factory :admin, class: 'User' do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    after(:build) { |user| user.webauth_groups = 'dlss:exhibits-admin' }
  end
end

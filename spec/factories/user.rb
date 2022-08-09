# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :curator, class: 'User' do
    sequence(:email) { |n| "curator#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end

  factory :admin, class: 'User' do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end

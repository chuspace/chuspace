# frozen_string_literal: true

FactoryBot.define do
  factory :user do |f|
    f.sequence(:email) { |n| "user#{n}@chuspace.com" }
    f.sequence(:first_name) { |n| "User #{n}" }
    f.sequence(:last_name) { |n| "User #{n}" }
    f.sequence(:username) { |n| "user-#{n}" }

    trait :gaurav do
      email { 'gaurav@chuspace.com' }
      username { 'gaurav' }
    end
  end
end

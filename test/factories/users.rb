# frozen_string_literal: true

FactoryBot.define do
  factory :user do |f|
    f.sequence(:email) { |n| "user#{n}@chuspace.com" }
    first_name { 'Gaurav' }
    last_name { 'Tiwari' }
    username { 'gaurav' }

    trait :gaurav do
      email { 'gaurav@chuspace.com' }
    end
  end
end

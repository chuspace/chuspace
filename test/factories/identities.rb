# frozen_string_literal: true

FactoryBot.define do
  factory :identity do |f|
    user
    f.sequence(:uid) { |n| "user#{n}@chuspace.com" }
    trait :email do
      provider { :email }
    end
  end
end

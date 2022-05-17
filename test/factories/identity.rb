# frozen_string_literal: true

FactoryBot.define do
  factory :identity do |f|
    f.sequence(:uid) { |n| "user#{n}@chuspace.com" }
    user
    trait :email do
      provider { :email }
    end
  end
end

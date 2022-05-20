# frozen_string_literal: true

FactoryBot.define do
  factory :publication do |f|
    association :owner, factory: :user
    git_provider
    personal { false }

    f.sequence(:name) { |n| "Rails #{n}" }

    before(:create) do |publication|
      publication.repository = FactoryBot.build :repository, publication: publication, git_provider: publication.git_provider
    end

    trait :personal do
      personal { true }
    end
  end
end

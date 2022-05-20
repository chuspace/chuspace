# frozen_string_literal: true

FactoryBot.define do
  factory :publication do |f|
    association :owner, factory: :user
    git_provider
    personal { false }

    f.sequence(:name) { |n| "Rails #{n}" }

    before(:create) do |publication|
      publication.repository = if publication.personal?
        FactoryBot.build :repository, :personal, publication: publication, git_provider: publication.git_provider
      else
        FactoryBot.build :repository, publication: publication, git_provider: publication.git_provider
      end
    end

    trait :personal do
      personal { true }
    end
  end
end

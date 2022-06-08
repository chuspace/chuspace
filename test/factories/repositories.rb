# frozen_string_literal: true

FactoryBot.define do
  factory :repository do |f|
    publication
    git_provider

    full_name { 'chuspace/test-blog' }
    posts_folder { '_posts' }
    assets_folder { '_posts' }
    readme_path { 'README.md' }

    trait :personal  do
      full_name { 'chuspace/personal-test-blog' }
    end
  end
end

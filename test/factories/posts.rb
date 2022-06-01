# frozen_string_literal: true

FactoryBot.define do
  factory :post do |f|
    association :author, factory: :user
    publication
    blob_path { 'src/pages/post/post.md' }
    blob_sha { 'ae4fbc773e1865ddc919c6eb7c6e2c68' }
    commit_sha { '7e4d1b8c42dc3e37a3b81805ce392722' }
    body { '# Post on Rails' }
    summary { 'Post on Rails' }
    date { Date.today }
    visibility { :public }

    f.sequence(:title) { |n| "Post #{n}" }

    trait :personal do
      personal { true }
    end
  end
end

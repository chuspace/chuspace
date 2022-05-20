# frozen_string_literal: true

FactoryBot.define do
  factory :repository do |f|
    publication
    git_provider

    full_name { 'chuspace/blog' }
    posts_folder { 'src/pages/posts' }
    assets_folder { 'public/assets/blog' }
  end
end

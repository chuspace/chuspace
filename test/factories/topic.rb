# frozen_string_literal: true

FactoryBot.define do
  factory :topic, class: 'ActsAsTaggableOn::Tag' do |f|
    name { 'react' }
    display_name { 'React' }
  end
end

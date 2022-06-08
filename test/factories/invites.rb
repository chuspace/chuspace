# frozen_string_literal: true

FactoryBot.define do
  factory :invite do |f|
    publication
    association :sender, factory: :user
    identifier { 'invite-1@chuspace.com' }
  end
end

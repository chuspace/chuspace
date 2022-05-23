# frozen_string_literal: true

FactoryBot.define do
  factory :kv do
    key { 'MyString' }
    value { 'MyText' }
    expires_in { nil }
    data_type { :string }
  end
end

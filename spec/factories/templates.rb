# frozen_string_literal: true

FactoryBot.define do
  factory :template do
    name { 'MyString' }
    permalink { 'MyString' }
    language { 'MyString' }
    framework { 'MyString' }
    path { 'MyString' }
    source { 'MyString' }
    articles_folder { 'MyString' }
    drafts_folder { 'MyString' }
    assets_folder { 'MyString' }
    readme { 'MyString' }
    visibility { 'MyString' }
    default { false }
  end
end

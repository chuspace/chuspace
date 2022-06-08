# frozen_string_literal: true

FactoryBot.define do
  factory :git_provider do |f|
    user
    app_installation_id { 26216689 }
    
    GitStorageConfig.new.github.each do |key, value|
      send(key) { value }
    end
  end
end

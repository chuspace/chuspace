# frozen_string_literal: true

class SeedGitProvidersJob < ApplicationJob
  def perform(user:)
    data = GitStorageConfig.new.to_h.map do |key, config|
      {
        user_id: user.id,
        created_at: Time.current,
        updated_at: Time.current,
        **config
      }
    end

    GitProvider.upsert_all(data, returning: false, unique_by: :one_provider_per_user)
  end
end

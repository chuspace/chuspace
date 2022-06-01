# frozen_string_literal: true

class SeedGitProvidersJob < ApplicationJob
  queue_as :critical

  def perform(user:)
    data = GitStorageConfig.new.to_h.map do |key, config|
      {
        user_id: user.id,
        created_at: Time.current,
        updated_at: Time.current,
        **config
      }
    end

    GitProvider.upsert_all(data)
  end
end

# frozen_string_literal: true

class CacheRepositoryReadmeJob < ApplicationJob
  def perform(repository:)
    repository.cache_readme!
    repository.reload.cache_readme_images!
  end
end

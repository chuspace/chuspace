# frozen_string_literal: true

class CachePostImagesJob < ApplicationJob
  def perform(post:)
    post.cache_images
  end
end

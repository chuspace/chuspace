# frozen_string_literal: true

class CachePostImagesJob < ApplicationJob
  queue_as :critical

  def perform(post:)
    post.cache_images
  end
end

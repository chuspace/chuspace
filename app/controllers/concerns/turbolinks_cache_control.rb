# frozen_string_literal: true

module TurbolinksCacheControl
  extend ActiveSupport::Concern

  included { before_action :disable_turbolinks_preview_cache, only: %i[new edit] }

  private

  def enable_turbolinks_cache
    @turbolinks_cache_control = 'cache'
  end

  def disable_turbolinks_cache
    @turbolinks_cache_control = 'no-cache'
  end

  def disable_turbolinks_preview_cache
    @turbolinks_cache_control = 'no-preview'
  end
end

# frozen_string_literal: true

module TurboCacheControl
  extend ActiveSupport::Concern

  included { before_action :disable_turbo_preview_cache, only: %i[new edit] }

  private

  def enable_turbo_cache
    @turbo_cache_control = 'cache'
  end

  def disable_turbo_cache
    @turbo_cache_control = 'no-cache'
  end

  def disable_turbo_preview_cache
    @turbo_cache_control = 'no-preview'
  end
end

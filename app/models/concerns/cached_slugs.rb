# frozen_string_literal: true

module CachedSlugs
  extend ActiveSupport::Concern

  class_methods do
    def friendly_fetch(slug, scope: nil)
      FriendlyId::Slug.fetch_by_slug_and_sluggable_type(slug, self.name)&.fetch_sluggable
    end

    def friendly_fetch!(slug, scope: nil)
      FriendlyId::Slug.fetch_by_slug_and_sluggable_type!(slug, self.name).fetch_sluggable
    end
  end
end

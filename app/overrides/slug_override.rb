# frozen_string_literal: true

module SlugOverride
  def self.prepended(base)
    base.include IdentityCache unless base.include?(IdentityCache)

    base.cache_index :slug, :sluggable_type, :scope, unique: true
    base.cache_index :slug, :sluggable_type, unique: true
    base.cache_index :sluggable_id, :sluggable_type

    base.cache_belongs_to :sluggable
  end

  FriendlyId::Slug.prepend self
end

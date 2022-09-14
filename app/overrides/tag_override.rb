# frozen_string_literal: true

module TagOverride
  def self.prepended(base)
    base.validates :name, presence: true, uniqueness: true
    base.scope :featured, -> { where(featured: true) }

    base.include Iconable
  end

  def to_param
    name
  end

  ActsAsTaggableOn::Tag.prepend self
end

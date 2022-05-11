# frozen_string_literal: true

module TagOverride
  def self.prepended(base)
    base.validates :name, presence: true, uniqueness: true
    base.scope :featured, -> { where(featured: true) }

    base.include PgSearch::Model

    base.multisearchable against: :name
    base.pg_search_scope :search_by_name,
                         against: %i[name description short_description],
                         using: {
                           tsearch: { prefix: true, dictionary: 'simple' }
                         }

    base.include Iconable
  end

  def to_param
    name
  end

  ActsAsTaggableOn::Tag.prepend self
end

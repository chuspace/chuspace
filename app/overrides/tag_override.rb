# frozen_string_literal: true

module TagOverride
  def self.prepended(base)
    base.include PgSearch::Model
    base.multisearchable against: :name
    base.pg_search_scope :search_by_name,
                         against: %i[name description short_description],
                         using: {
                           tsearch: { prefix: true, dictionary: 'simple' }
                         }
  end

  ActsAsTaggableOn::Tag.prepend self
end

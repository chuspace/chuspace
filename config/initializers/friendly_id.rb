# frozen_string_literal: true

FriendlyId.defaults do |config|
  config.use :reserved
  config.reserved_words = %w(
    new publications publication admin blog blogs
    edit index session login logout users admin
    git_providers users oauths topics posts errors
    welcome hello stylesheets assets javascripts images
    privacy terms home settings webhooks drafts
  )

  config.treat_reserved_as_conflict = false
  config.use :slugged
  config.slug_limit = 80
  config.sequence_separator = '--'

  config.use Module.new {
    def normalize_friendly_id(text)
      text.to_slug.normalize! transliterations: %i[russian latin]
    end
  }
end

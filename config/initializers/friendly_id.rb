# frozen_string_literal: true

FriendlyId.defaults do |config|
  config.use :reserved
  config.reserved_words = %w(
    new chu chuspace purge
    publications publication admin blog blogs
    terms privacy superuser self chu-space
    edit index session login logout users admin
    stylesheets assets javascripts images
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

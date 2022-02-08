# frozen_string_literal: true

class PublicationSettings
  include ActiveModel::API

  PAGES = %w[profile content front_matter permissions deployment].freeze
  DEFAULT_PAGE = :profile
end

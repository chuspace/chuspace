# frozen_string_literal: true

class PublicationSetting
  include ActiveModel::API

  PAGES = %w[profile content front_matter].freeze
  DEFAULT_PAGE = :profile
end

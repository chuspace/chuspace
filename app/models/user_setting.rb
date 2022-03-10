# frozen_string_literal: true

class UserSetting
  include ActiveModel::API

  PAGES = %w[profile publication front_matter permissions].freeze
  DEFAULT_PAGE = :profile
end

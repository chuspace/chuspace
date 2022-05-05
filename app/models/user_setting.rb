# frozen_string_literal: true

class UserSetting
  include ActiveModel::API

  PAGES = %w[profile publication].freeze
  DEFAULT_PAGE = :profile
end

# frozen_string_literal: true

class UserTab
  include ActiveModel::API

  PAGES = %w[publications drafts posts].freeze
end

# frozen_string_literal: true

class UserTab
  include ActiveModel::API

  PAGES = %w[org_publications drafts posts].freeze
end

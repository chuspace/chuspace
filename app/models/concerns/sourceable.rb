# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern
  DEFAULT_COMMIT_SOURCE = 'chuspace'

  included do
    before_validation :assign_commit_source, on: :create

    enum source: {
      chuspace: DEFAULT_COMMIT_SOURCE,
      remote: 'remote'
    }, _suffix: true
  end

  private

  def assign_commit_source
    self.source ||= DEFAULT_COMMIT_SOURCE
  end
end

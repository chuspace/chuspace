# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern
  DEFAULT_ORIGINATOR = 'chuspace'

  included do
    before_validation :assign_originator, on: :create

    enum originator: {
      chuspace: DEFAULT_ORIGINATOR,
      github: 'github',
      gitlab: 'gitlab'
    }, _suffix: true
  end

  private

  def assign_originator
    self.originator ||= DEFAULT_ORIGINATOR
  end
end

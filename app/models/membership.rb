# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :publication
  belongs_to :user

  enum role: RolesConfig.to_enum

  DEFAULT_ROLE = :writer

  def self.publishers
    where(role: %w[editor manager])
  end
end

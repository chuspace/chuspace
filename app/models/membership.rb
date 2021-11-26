# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :blog
  belongs_to :user

  enum role: RolesConfig.to_enum

  DEFAULT_ROLE = :writer
end

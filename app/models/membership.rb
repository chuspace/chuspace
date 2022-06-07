# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :publication
  belongs_to :user

  validates :publication_id, uniqueness: { scope: :user_id }
  
  enum role: RolesConfig.to_enum

  DEFAULT_ROLE = :writer

  class << self
    def admins
      where(role: RolesConfig.admins)
    end

    def editors
      where(role: RolesConfig.editors)
    end

    def publishers
      where(role: RolesConfig.publishers)
    end

    def writers
      where(role: RolesConfig.writers)
    end
  end
end

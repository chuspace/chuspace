# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user

  encrypts :uid
  blind_index :uid

  enum provider: OmniauthConfig.providers_enum
end

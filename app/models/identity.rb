# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user

  encrypts :uid, deterministic: true, downcase: true
  enum provider: OmniauthConfig.providers_enum
end

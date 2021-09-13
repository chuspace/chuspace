# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user

  encrypts :uid
  blind_index :uid

  enum provider: {
    github: 'github',
    gitlab: 'gitlab',
    email: 'email'
  }, _suffix: true
end

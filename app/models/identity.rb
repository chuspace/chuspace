# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user

  encrypts :uid, :access_token, :access_token_secret
  blind_index :uid, slow: true

  enum provider: {
    github: 'github',
    gitlab: 'gitlab',
    bitbucket: 'bitbucket',
    email: 'email'
  }, _suffix: true
end

# frozen_string_literal: true

class OmniauthConfig < ApplicationConfig
  attr_config(
    github: {
      scope: 'read:user,user:email'
    },
    gitlab: {
      scope: 'read_user email profile'
    },
    bitbucket: {
      scope: 'email account'
    }
  )
end

# frozen_string_literal: true

class GitConfig < ApplicationConfig
  attr_config(
    github: {
        committer: {
        name: 'chuspace-dev[bot]',
        email: '104423298+chuspace-dev[bot]@users.noreply.github.com',
        date: Date.today
      }
    }
  )
end

# frozen_string_literal: true

class GitConfig < ApplicationConfig
  attr_config(committer: {
    name: 'chuspace-dev[bot]',
    email: '160985+chuspace-dev[bot]@users.noreply.github.com',
    date: Date.today
  })
end

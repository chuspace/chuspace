# frozen_string_literal: true

class GitConfig < ApplicationConfig
  attr_config(committer: {
    name: 'Chuspace',
    email: 'chuspace-user@no-reply.chuspace.com',
    date: Date.today
  })
end

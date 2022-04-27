# frozen_string_literal: true

class ChuspaceConfig < ApplicationConfig
  attr_config(
    app: {
      name: 'Chuspace',
      twitter: '@chuspace_com'
    },
    revision: {
      default_status: 'open',
      statuses: {
        open: 'open',
        closed: 'closed',
        merged: 'merged'
      }
    }
  )
end

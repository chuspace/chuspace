# frozen_string_literal: true

class ChuspaceConfig < ApplicationConfig
  attr_config(
    app: {
      name: 'Chuspace',
      twitter: '@chuspace_com',
      out_of_private_beta: ENV['OUT_OF_PRIVATE_BETA'] || true
    },

    collaboration_session: {
      states: {
        open: :open,
        closed: :closed,
        stale: :stale
      }
    },

    revision: {
      states: {
        draft: :draft,
        open: :open,
        closed: :closed,
        merged: :merged,
        rejected: :rejected
      }
    }
  )
end

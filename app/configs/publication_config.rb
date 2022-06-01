# frozen_string_literal: true

class PublicationConfig < ApplicationConfig
  attr_config(
    front_matter: {
      keys: %i[title summary date topics canonical_url published],
      title: :title,
      summary: :summary,
      date: :date,
      topics: :topics,
      canonical_url: :canonical_url,
      published: :published
    },
    repo: {
      readme_path: 'README.md'
    },
    revision: {
      default_status: 'open',
      statuses: {
        open: 'open',
        closed: 'closed',
        merged: 'merged'
      }
    },
    settings: {
      auto_publish: false
    },
    visibility: {
      private: 'private',
      public: 'public',
      member: 'member',
      internal: 'internal'
    }
  )

  def self.to_enum
    defaults['visibility']
  end
end

# frozen_string_literal: true

class PublicationConfig < ApplicationConfig
  attr_config(
    front_matter: {
      title: :title,
      summary: :summary,
      date: :date,
      topics: :topics,
      published: :published
    },
    repo: {
      readme_path: 'README.md'
    },
    settings: {
      auto_publish: false
    },
    visibility: {
      private: 'private',
      public: 'public',
      member: 'member'
    }
  )

  def self.to_enum
    defaults['visibility']
  end
end

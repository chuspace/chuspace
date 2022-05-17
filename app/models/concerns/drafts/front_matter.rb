# frozen_string_literal: true

module Drafts
  module FrontMatter
    extend ActiveSupport::Concern

    def front_matter
      (parsed&.front_matter.presence || {}).with_indifferent_access
    end

    def front_matter?
      !readme?
    end

    def front_matter_str
      str = front_matter.to_yaml
      str += "---\n"
    end

    def canonical_url
      front_matter.dig(publication.front_matter.canonical_url)
    end

    def date
      front_matter.dig(publication.front_matter.date)
    end

    def summary
      front_matter.dig(publication.front_matter.summary)
    end

    def title
      front_matter.dig(publication.front_matter.title)
    end

    def topics
      front_matter.dig(publication.front_matter.topics)
    end
  end
end

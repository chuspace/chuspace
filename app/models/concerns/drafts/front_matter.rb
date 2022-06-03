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
      front_matter_date = front_matter.dig(publication.front_matter.date)

      if front_matter_date && front_matter_date < Date.today
        Date.today
      else
        front_matter_date
      end
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

    def unlisted
      front_matter.dig(:unlisted) || false
    end

    def permalink
      front_matter.dig(:permalink)
    end

    def visibility
      front_matter.dig(:visibility) || :public
    end
  end
end

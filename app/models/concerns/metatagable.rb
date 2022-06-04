# frozen_string_literal: true

module Metatagable
  extend ActiveSupport::Concern

  def to_meta_tags
    options = {
      site: ChuspaceConfig.new.app[:name],
      title: og_title,
      image_src: og_image_url,
      description: og_description,
      keywords: topic_list,
      canonical: url,
      og: {
        title: :title,
        type: is_a?(Post) ? :article : :website,
        description: :description,
        site_name: :site,
        image: :image_src,
        url: :canonical
      },
      twitter: {
        title: :title,
        card: :summary_large_image,
        creator: og_creator,
        description: :description,
        widgets: {
          'new-embed-design': 'on'
        },
        site: ChuspaceConfig.new.app[:twitter],
        image: :image_src,
        url: :canonical,
      }
    }

    options.merge(article: { published_time: date, modified_time: updated_at, tag: topic_list, author: author.username }) if is_a?(Post)
    options
  end

  private

  def og_creator
    case self
    when Publication then twitter_handle
    when Post then publication.twitter_handle
    end
  end

  def og_title
    case self
    when Publication then name
    when Post then title
    end
  end

  def og_description
    case self
    when Publication then description
    when Post then summary
    end
  end

  def og_image_url
    @og_image_url ||= case self
                      when Publication then cdn_icon_url(variant: :profile)
                      when Post then featured_image&.cdn_image_url(variant: :social)
    end
  end

  def url
    case self.class
    when Publication then canonical_url || Rails.application.routes.url_helpers.publication_url(self)
    when Post then canonical_url || Rails.application.routes.url_helpers.post_publication_url(publication, self)
    end
  end
end

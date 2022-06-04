# frozen_string_literal: true

module Iconable
  extend ActiveSupport::Concern

  ICON_VARIANTS = {
    mini: 64,
    thumb: 200,
    profile: 500
  }

  included do
    has_one_attached :icon do |attachable|
      ICON_VARIANTS.each do |name, size|
        attachable.variant name, resize_to_fill: [size, size]
      end
    end

    validates :icon, attached: false,
                       size: { less_than: 5.megabytes, message: 'should be less than 5 megabytes' },
                       content_type: ['image/png', 'image/jpeg', 'image/gif', 'image/webp', 'image/jpg']
  end

  def cdn_icon_url(variant: :mini)
    if icon.attached?
      if icon.variable?
        Rails.application.routes.url_helpers.rails_public_blob_url(icon.variant(variant))
      else
        Rails.application.routes.url_helpers(icon)
      end
    end
  end
end

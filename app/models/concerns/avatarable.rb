# frozen_string_literal: true

module Avatarable
  extend ActiveSupport::Concern
  class AvatarVariantNotFound < StandardError; end

  AVATAR_VARIANTS = {
    mini: 64,
    thumb: 200,
    profile: 400
  }

  included do
    has_one_attached :avatar do |attachable|
      AVATAR_VARIANTS.each do |name, size|
        attachable.variant name, resize_to_fill: [size, size]
      end
    end

    validates :avatar, attached: false,
                       size: { less_than: 5.megabytes, message: 'should be less than 5 megabytes' },
                       content_type: ['image/png', 'image/jpeg', 'image/gif', 'image/webp', 'image/jpg']
  end

  def gravatar_url(variant: :mini)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end

  def cdn_avatar_url(variant: :mini)
    if avatar.attached?
      if avatar.variable?
        Rails.application.routes.url_helpers.rails_public_blob_url(avatar.variant(variant))
      else
        Rails.application.routes.url_helpers(avatar)
      end
    end
  end
end

# frozen_string_literal: true

module Avatarable
  extend ActiveSupport::Concern

  AVATAR_VARIANTS = {
    icon: 32,
    thumb: 100,
    profile: 250
  }

  included do
    has_one_attached :avatar do |attachable|
      AVATAR_VARIANTS.each do |name, size|
        attachable.variant name, resize_to_limit: [size, size]
      end
    end
  end

  def avatar_url(variant: :icon)
    avatar.variant(variant) || gravatar_url(variant: variant)
  end

  private

  def gravatar_url(variant: :icon)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end
end

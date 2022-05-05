# frozen_string_literal: true

module Avatarable
  extend ActiveSupport::Concern
  class AvatarVariantNotFound < StandardError; end

  AVATAR_VARIANTS = {
    icon: {
      size: 32,
      classname: 'w-8 rounded-full'
    },
    thumb: {
      size: 100,
      classname: 'w-16 rounded-full'
    },
    profile: {
      size: 200,
      classname: 'w-32 rounded-full'
    }
  }

  included do
    has_one_attached :avatar do |attachable|
      AVATAR_VARIANTS.each do |name, config|
        attachable.variant name, resize_to_limit: [config[:size], config[:size]]
      end
    end

    validates :avatar, attached: true,
                       size: { less_than: 5.megabytes, message: 'should be less than 5 megabytes' },
                       content_type: ['image/png', 'image/jpeg', 'image/gif', 'image/webp', 'image/svg+xml', 'image/jpg']
  end

  def avatar_url(variant: :icon)
    avatar.variant(variant) || gravatar_url(variant: variant)
  end

  private

  def gravatar_url(variant: :icon)
    size = AVATAR_VARIANTS[variant][:size] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end
end

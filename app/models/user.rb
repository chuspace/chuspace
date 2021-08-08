# frozen_string_literal: true

class User < ApplicationRecord
  include Trackable
  has_one_attached :avatar
  has_many :blogs
  has_many :identities

  encrypts :email
  blind_index :email, slow: true

  AVATAR_VARIANTS = { xs: 32, sm: 48, md: 64, lg: 80, xl: 120, thumb: 150, profile: 250 }.freeze

  def avatar_url
    avatar.variant(resize_to_fit: [100, 100])&.processed&.url || gravatar_url
  end

  def gravatar_url(variant: :xs)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end
end

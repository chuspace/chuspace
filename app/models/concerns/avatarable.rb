# frozen_string_literal: true

module Avatarable
  extend ActiveSupport::Concern

  AVATAR_VARIANTS = {
    xs: 32,
    sm: 48,
    md: 64,
    lg: 80,
    xl: 120,
    thumb: 150,
    profile: 250
  }.freeze

  def gravatar_url(variant: :xs)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end

  alias avatar_url gravatar_url
end

# frozen_string_literal: true

class User < ApplicationRecord
  include Trackable

  has_many :blogs, dependent: :delete_all
  has_many :storages, dependent: :delete_all
  has_many :identities, dependent: :delete_all

  encrypts :email, deterministic: true, downcase: true

  AVATAR_VARIANTS = { xs: 32, sm: 48, md: 64, lg: 80, xl: 120, thumb: 150, profile: 250 }.freeze

  def avatar_url(variant: :xs)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_url(variant: variant)
  end

  def gravatar_url(variant: :xs)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end

  def enable_default_blogging
    ChuspaceAdapter.as_superuser.create_user(user: self)
    adapter = ChuspaceAdapter.as_superuser
    adapter.basic_auth = true
    adapter.sudo = username

    access_token = adapter.create_personal_access_token(user: self)
    storage = storages.create!(access_token: access_token, provider: :chuspace)

    storage.blogs.create!(
      user: self,
      name: username,
      default: true,
      visibility: :internal,
      **BlogFrameworkConfig.default.slice(:framework, :posts_folder, :drafts_folder, :assets_folder)
    )
  end

  def to_param
    username
  end
end

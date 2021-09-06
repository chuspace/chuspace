# frozen_string_literal: true

class User < ApplicationRecord
  include Trackable
  extend FriendlyId
  friendly_id :name, use: %i[slugged history finders], slug_column: :username

  has_one_attached :avatar
  has_many :blogs, dependent: :delete_all
  has_many :storages, dependent: :delete_all
  has_many :identities, dependent: :delete_all

  # Creates user account on Chuspace git storage
  # and adds a personal access token for scoped access
  after_create_commit :prepare_for_blogging

  encrypts :email
  blind_index :email, slow: true

  AVATAR_VARIANTS = { xs: 32, sm: 48, md: 64, lg: 80, xl: 120, thumb: 150, profile: 250 }.freeze

  def avatar_url(variant: :lg)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    avatar.variant(resize_to_fit: [size, size])&.processed&.url || gravatar_url
  end

  def gravatar_url(variant: :xs)
    size = AVATAR_VARIANTS[variant] || fail(AvatarVariantNotFound, 'Avatar variant not found')
    gravatar_id = Digest::MD5.hexdigest(email)
    "//secure.gravatar.com/avatar/#{gravatar_id}?d=identicon&s=#{size}"
  end

  private

  def prepare_for_blogging
    provider_user_id, access_token = ::Storage.chuspace_adapter.create_user_with_token(user: self)

    storage = storages.create!(
      provider_user_id: provider_user_id,
      access_token: access_token,
      **GitStorageConfig.chuspace.slice(:description, :endpoint, :provider)
    )

    storage.blogs.create!(
      user: self,
      name: "#{self.name} blog",
      default: true,
      visibility: :internal,
      **BlogFrameworkConfig.default.slice(:framework, :posts_folder, :drafts_folder, :assets_folder)
    )
  end
end
